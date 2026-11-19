module SalaryRecords
  class Create < Trailblazer::Operation
    step :authorize
    step :find_employee_detail
    fail :employee_not_found, fail_fast: true

    step :validate_month_year
    fail :invalid_month_year, fail_fast: true

    step :calculate_salary
    fail :collect_errors, fail_fast: true

    step :save_salary_record
    fail :handle_errors
    step :success_response

    include CalculateMonthlySalary

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::SalaryRecord, :create?)
    end

    def find_employee_detail(ctx, params:, **)
      employee_detail_id = params[:employee_detail_id] || params[:employee_id]

      employee_detail = EmployeeDetail.find_by(id: employee_detail_id)

      unless employee_detail
        ctx[:errors] = [ "Employee details not found" ]
        return false
      end

      ctx[:employee_detail] = employee_detail
      true
    end

    def employee_not_found(ctx, **)
      ctx[:response] = {
        message: "Salary record creation failed",
        errors: ctx[:errors]
      }
      ctx[:status] = :not_found
    end

    def validate_month_year(ctx, params:, **)
      month = params[:month].to_i
      year = params[:year].to_i

      unless month.between?(1, 12) && year.positive?
        ctx[:errors] = [ "Invalid month or year" ]
        return false
      end

      start_date = Date.new(year, month, 1)

      if start_date > Date.current.beginning_of_month
        ctx[:errors] = [ "Cannot generate salary for a future month" ]
        return false
      end

      end_date = [ start_date.end_of_month, Date.current ].min

      ctx[:month] = month
      ctx[:year] = year
      ctx[:start_date] = start_date
      ctx[:end_date] = end_date

      true
    rescue Date::Error
      ctx[:errors] = [ "Invalid month or year" ]
      false
    end

    def invalid_month_year(ctx, **)
      ctx[:response] = {
        message: "Salary record creation failed",
        errors: ctx[:errors]
      }
      ctx[:status] = :unprocessable_entity
    end

    def calculate_salary(ctx, employee_detail:, start_date:, end_date:, **)
      current_salary = calculate_month_salary(
        employee_detail,
        start_date,
        end_date
      )

      unless current_salary
        ctx[:errors] = [ "No working days found for this month" ]
        return false
      end

      previous_start = start_date.prev_month.beginning_of_month
      previous_end = previous_start.end_of_month
      previous_record = SalaryRecord.find_by(
        employee_detail_id: employee_detail.id,
        month: previous_start.month,
        year: previous_start.year
      )

      salary_adjustments = 0.to_d

      if previous_record
        corrected_previous_salary = calculate_month_salary(
          employee_detail,
          previous_start,
          previous_end
        )

        if corrected_previous_salary
          previous_original_payable =
            previous_record.payable_salary.to_d -
            previous_record.salary_adjustments.to_d

          salary_adjustments =
            corrected_previous_salary[:payable_salary] - previous_original_payable
        end
      end

      payable_salary = current_salary[:payable_salary] + salary_adjustments

      ctx[:salary_attributes] = {
        employee_detail_id: employee_detail.id,
        month: ctx[:month],
        year: ctx[:year],
        base_salary: current_salary[:base_salary],
        present_days: current_salary[:present_days],
        approved_leave_days: current_salary[:approved_leave_days],
        paid_leave_days: current_salary[:paid_leave_days],
        salary_adjustments: salary_adjustments.round(2),
        payable_salary: payable_salary.round(2)
      }

      true
    end

    def save_salary_record(ctx, salary_attributes:, **)
      salary_record = SalaryRecord.find_or_initialize_by(
        employee_detail_id: salary_attributes[:employee_detail_id],
        month: salary_attributes[:month],
        year: salary_attributes[:year]
      )

      salary_record.assign_attributes(salary_attributes)

      if salary_record.save
        ctx[:salary_record] = salary_record
        true
      else
        ctx[:errors] = salary_record.errors.full_messages
        false
      end
    end

    def handle_errors(ctx, **)
      ctx[:response] = {
        message: "Salary calculation failed",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Salary record created successfully",
        data: ctx[:salary_record]
      }
      ctx[:status] = :created
      true
    end
  end
end
