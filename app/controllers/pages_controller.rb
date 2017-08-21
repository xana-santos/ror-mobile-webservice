class PagesController < ApplicationController
  
  def terms
    @terms = current_terms.include?(params["terms"]) ? params["terms"] : "client"
  end
  
  def home
    redirect_to "http://www.positivflo.com.au" and return unless Rails.env.development?
    redirect_to documentation_path and return if Rails.env.development?
  end
  
  private
  
  def current_terms
    ["trainer", "client", "privacy"]
  end
  
end
