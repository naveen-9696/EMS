
module Employees
  class EmployeeService
    def self.create(params)
      EmployeeDetail.create!(
        user_id: params[:user_id],
        department_id: params[:department_id],
        designation: params[:designation],
        base_salary: params[:base_salary]
      )
    end

    def self.all
      EmployeeDetail.includes(:user, :department).all
    end

    def self.find(id)
      EmployeeDetail.includes(:user, :department).find(id)
    end
  end
end
