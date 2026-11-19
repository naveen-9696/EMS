module SalaryRecords
  class Show < Trailblazer::Operation
    step :find_salary_record
    step :authorize
    step :success_response

    fail :salary_record_not_found, fail_fast: true

    def find_salary_record(ctx, params:, **)
      record = SalaryRecord.includes(
        employee_detail: [ :user, :department ]
      ).find_by(id: params[:id])

      unless record
        return false
      end

      ctx[:salary_record] = record
      true
    end

    def salary_record_not_found(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch salary record",
        errors: [ "Salary record not found" ]
      }
      ctx[:status] = :not_found
    end

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ctx[:salary_record], :show?)
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Salary record fetched successfully",
        data: ctx[:salary_record].as_json
      }
      ctx[:status] = :ok
      true
    end
  end
end
