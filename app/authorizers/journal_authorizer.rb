class JournalAuthorizer < ApplicationAuthorizer

  #############
  # CREATABLE #
  #############

  #
  # Class wide test to see if any
  # user is able to create a new
  # journal. This is forbidden by
  # all users, as journals are 
  # automatically created
  #
  def self.creatable_by?(user)
    false
  end


  #############
  # DELETABLE #
  #############

  #
  # Class wide test to see if any
  # user can delete a journal. This
  # is forbidden by all users.
  #
  def self.deletable_by?(user)
    false
  end
   
  def deletable_by?(user)
    false
  end

  #############
  # UPDATABLE #
  #############

  #
  # Class wide test to see if a user
  # can update ANY journal.
  #
  # Journals cannot be updated
  #
  def self.updatable_by?(user)
    false
  end

  #
  # Instance level test to see if a
  # user can update the specific journal.
  #
  # Journals cannot be updated
  #
  def updatable_by?(user)
    false
  end


  ############
  # READABLE #
  ############

  #
  # Class wide test to see if a user
  # can read ANY journal. This doesn't
  # grant a user to view an individual
  # alert.
  #
  def self.readable_by?(user)
    return true if owner_is_installation?
    AlertAuthorizer.readable_by?(user)
  end

  #
  # Instance level test to see if a
  # user can read the specific journal.
  #
  # Journals belong to alerts, and
  # therefore have the same reading
  # permissions as alerts.
  #
  def readable_by?(user)
    return true if owner_is_installation?
    alert = resource.alert
    return false unless alert

    alert.authorizer.readable_by?(user)
  end

end