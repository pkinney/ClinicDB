class ImmunizationController < ApplicationController
	active_scaffold :immunization do |config|
		config.columns = [:immunization_drug, :lot_number, :expiration_date, :notes, :patient]
	end
	
	def add_for_patient
    immu = Immunization.new(params[:immunization])
    immu.givenby_user = User.find(params[:givenby_user_id])
    immu.given_date = Date.today()
    
    expdate = params[:other][:expiration_date]
    nums = (expdate.count('-')>0) ? expdate.split('-') : expdate.split('/')
    
    if nums.size==3
      month = nums[0].to_i
      day = nums[1].to_i
      year = nums[2].to_i
    elsif nums.size==2
      month = nums[0].to_i
      day = 1
      year = nums[1].to_i
    end
    
    year = year<100 ? year + 2000 : year
    
    immu.expiration_date = Date.civil(year, month, day)
     
    flash[:warning] = "#{immu.name} batch expires on #{expdate}" if immu.expiration_date - 28 < Date.today()
    
    if immu.save
      flash[:notice] = "Immunization saved"
      Transaction.log_edit_patient(session[:user].id, immu.patient_id)
      redirect_to :controller => 'home', :action => 'patient_home', :patient_id => immu.patient_id
    else
      flash[:error] = "Error saving immunization."
      redirect_to :back
    end
  end
  
  def for_patient
    @patient = Patient.find(params[:patient_id])
    @dates = @patient.dates.sort.reverse.select{|a| @patient.immunizations_for_date(a).length > 0}
    
    @immus = {}
    for date in @dates
      @immus[date.to_s] = @patient.immunizations_for_date(date)
    end
  end
end
