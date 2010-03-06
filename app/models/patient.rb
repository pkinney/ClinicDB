class Patient < ActiveRecord::Base
	has_many :visits
	has_many :tb_tests
	belongs_to :ethnicity
	
	has_and_belongs_to_many :childhood_diseases
	has_and_belongs_to_many :family_histories
	has_and_belongs_to_many :immunization_histories
	
	has_many :prescriptions
	has_many :immunizations
	
	validates_presence_of :first_name
	validates_presence_of :last_name
	validates_presence_of :dob
  validates_presence_of :sex
  validates_presence_of :ethnicity_id
  
  before_save      EncryptionWrapper.new(["last_name", "first_name", "adult_illness", "surgeries", "allergies", "drug_notes", "etoh_notes"])
  after_save       EncryptionWrapper.new(["last_name", "first_name", "adult_illness", "surgeries", "allergies", "drug_notes", "etoh_notes"])
  after_find       EncryptionWrapper.new(["last_name", "first_name", "adult_illness", "surgeries", "allergies", "drug_notes", "etoh_notes"])
  after_initialize EncryptionWrapper.new(["last_name", "first_name", "adult_illness", "surgeries", "allergies", "drug_notes", "etoh_notes"])
  
  def after_find
  end
	
  def patient_number
    PatientIdentifier.get_or_create_for_patient(self).identifier
  end
  
	def to_label
	  "#{last_name}, #{first_name} (#{dob_str})"
	end
	
	def dob_str
	  '%d/%d/%02d' % [dob.mon, dob.mday, dob.year]
  end
  
  def age
    Date.today().year - dob.year - ((dob.mon*100+dob.mday >  Date.today().mon*100+Date.today().mday) ? 1 : 0)
  end
  
  def name
	  "#{last_name}, #{first_name}"
  end
  
  def properLastName
    "#{isMale? ? 'Mr.' : 'Ms.'} #{last_name}"
  end
  
  def isMale?
    sex=='Male'
  end
  
  def visit_for_date(date)
    on = visits.select {|a| a.visit_date == date}
    if on.length > 0
      return on[0]
    end
    nil
  end
end
