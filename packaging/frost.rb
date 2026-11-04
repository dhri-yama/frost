# Homebrew cask for Frost. Copy to Casks/frost.rb in the tap repository (dhri-yama/homebrew-tap), then update `version` and
# `sha256` for each release (./publish.sh prints the sha256).
cask "frost" do
  version "0.16.0"
  sha256 "0705425496b0696ed7e9e37545daf038ff87261685d5e21a506ec0fbe119a8b7"

  url "https://github.com/dhri-yama/frost/releases/download/v#{version}/Frost-#{version}.dmg"
  name "Frost"
  desc "Menu bar organiser that hides icons and brings them back on demand"
  homepage "https://github.com/dhri-yama/frost"

  depends_on macos: ">= :ventura"

  app "Frost.app"

  zap trash: [
    "~/Library/Preferences/io.github.dhri-yama.frost.plist",
  ]
end
