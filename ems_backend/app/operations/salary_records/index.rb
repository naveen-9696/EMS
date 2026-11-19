module SalaryRecords
  class Index < Trailblazer::Operation
    step :authorize
    step :fetch_salary_records
    step :success_response
    fail :collect_errors

    def authorize(ctx, current_user:, **)
      Pundit.authorize(current_user, ::SalaryRecord, :index?)
    end

    def fetch_salary_records(ctx, current_user:, **)
      ctx[:salary_records] = Pundit.policy_scope!(current_user, ::SalaryRecord)
      true
    end

    def success_response(ctx, **)
      ctx[:response] = {
        message: "Salary records fetched successfully",
        data: ctx[:salary_records]
      }
      ctx[:status] = :ok
      true
    end

    def collect_errors(ctx, **)
      ctx[:response] = {
        message: "Failed to fetch salary records",
        errors: ctx[:errors] || [ "Unknown error" ]
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
