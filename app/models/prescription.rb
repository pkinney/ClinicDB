class Prescription < ActiveRecord::Base
	belongs_to :patient
	belongs_to :drug
	
	validates_presence_of :drug_id
	validates_presence_of :signed
	validates_presence_of :patient_id
	
	before_save      EncryptionWrapper.new(["orders","signed","notes"])
  after_save       EncryptionWrapper.new(["orders","signed","notes"])
  after_find       EncryptionWrapper.new(["orders","signed","notes"])
  after_initialize EncryptionWrapper.new(["orders","signed","notes"])

  def after_find
    
  end
  
	def to_label
		"#{drug.name} - #{orders}"
	end
end
