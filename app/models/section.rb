class Section < ApplicationRecord
  require 'roo'

  has_many :comments, dependent: :destroy

  def section_number_zeroed
    section_number.to_s.rjust(3, "0")
  end

  def section_and_number
    "#{course_description}-#{section_number_zeroed}"
  end

  def self.department_list
     self.all.map{|s| s.department}.uniq
  end

  def self.import(filepath)
    # Grab most recent update time
    last_touched_at = Section.maximum(:updated_at)
    # Open file using Roo
    spreadsheet = Roo::Spreadsheet.open(filepath, extension: :xlsx)
    # Use local names instead of names from file header
    header = %w[section_id term department cross_list_group course_description section_number title credits level status enrollment_limit actual_enrollment cross_list_enrollment waitlist]
    # Parse spreadsheet.
    @updated_sections = 0
    # We will skip the first three rows (non-spreadsheet message and headers) and the last two (blank line and disclaimer).
    last_real_row = spreadsheet.last_row - 2
    (4..last_real_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      section = Section.find_or_initialize_by(term: row["term"], section_id: row["section_id"])
      section.attributes = row.to_hash.slice(*header)
      report_action('New Sections', section.section_and_number) if section.new_record?

      # TODO: do we have a flag for cancellation?
      if section.status == 'C'
        if section.status_changed? || section.canceled_at.blank?
          puts "NEW CANCEL! - #{section.status_changed?} - #{section.canceled_at.blank?}"
          section.canceled_at = DateTime.now()
          report_action('Canceled Sections', section.section_and_number)
        end
      end

      # Save if changed, touch if unchanged
      if section.changed?
        section.save!
        @updated_sections += 1
      else
        (section.touch unless section.new_record?)
      end
      puts row
    end


    # Used last_touched_at to determine which terms were updated
    touched = Section.where('updated_at > ?', last_touched_at)
    created = Section.where('created_at > ?', last_touched_at)
    @touched_sections = touched.size - created.size
    @new_sections = created.size
    if touched.size > 0
      report_action('Updated Sections', "#{@updated_sections} sections were updated during the import process. #{@new_sections} sections were created.")
    else
      report_action('Updated Sections', 'The import file was empty.')
    end
    # From those, gather the terms
    touched_terms = touched.collect { |touched| touched.term }.uniq
    # Then find any untouched sections from those terms
    untouched = Section.where('updated_at <= ? and term in (?)', last_touched_at, touched_terms)
    if untouched.size > 0
      report_action('Updated Sections', "#{untouched.size} sections from terms contained in feed were not touched by import. It is possible that these were cancelled.")
    else
      report_action('Updated Sections', 'All sections were touched by the import process.')
    end
    # puts @report
    ActionCable.server.broadcast 'room_channel',
                                 body:  "Registration data import complete. #{@new_sections} added. #{@updated_sections} updated. Refreshing browser to show changes.",
                                 section_name: "Data Updated",
                                 user: "System"
  end

  def self.report_action(subject, message)
    @report ||= Hash.new
    @report[subject] ||= []
    @report[subject] << message
    puts message
  end

end
