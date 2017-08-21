RSpec.feature "PI Pages", type: :feature do
  
  scenario "User visits wrong api page" do
    visit "/invalid_url"
    expect(page).to have_text("404")
  end
  
end
