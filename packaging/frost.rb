# Homebrew cask for Frost. Copy to Casks/frost.rb in the tap repository (dhri-yama/homebrew-tap), then update `version` and
# `sha256` for each release (./publish.sh prints the sha256).
cask "frost" do
  version "0.15.1"
  sha256 "REPLACE_WITH_SHA256_FROM_PUBLISH_SH"

  url "https://github.com/dhri-yama/frost/releases/download/v#{version}/Frost-#{version}.dmg"
  name "Frost"
  desc "Menu bar organiser that hides icons and brings them back on demand"
  homepage "https://github.com/dhri-yama/frost"

  depends_on macos: ">= :ventura"

  app "Frost.app"

  zap trash: [
    "~/Library/Preferences/local.frost.plist",
  ]
end
