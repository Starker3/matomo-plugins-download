# Put your Matomo Marketplace license key in the double quotes below.
# Get your license key @ https://shop.matomo.org/my-account/
LICENSE_KEY=""

if [ -z "$LICENSE_KEY" ]
  then
    echo -e "Please check your Matomo Marketplace license key is correct, and try again." >&2
    exit 1
fi

mkdir "plugins-downloaded" || { echo "Please delete the directory plugins-downloaded/ before proceeding. The Matomo plugins will be extracted in this directory." ; exit; }

if [ -z "$1" ]
  then
    MATOMO_CORE_VERSION=$(curl -f -sS https://api.matomo.org/1.0/getLatestVersion/) || die "Failed to fetch the latest Matomo version."
    echo -e "No version supplied, getting plugins for the latest stable $MATOMO_CORE_VERSION..."
  else
    MATOMO_CORE_VERSION=$1
fi

function die() {
	echo -e "$0: $1"
	exit 2
}

PLUGINS_TO_DOWNLOAD="CustomReports MarketingCampaignsReporting CustomAlerts LogViewer InvalidateReports TasksTimetable QueuedTracking AbTesting MediaAnalytics FormAnalytics Funnels RollUpReporting SearchEngineKeywordsPerformance MultiChannelConversionAttribution HeatmapSessionRecording SEOWebVitals UsersFlow ActivityLog WhiteLabel Cohorts AdvertisingConversionExport LoginSaml"

for PLUGIN_NAME in $PLUGINS_TO_DOWNLOAD
do
    echo "Downloading plugin $PLUGIN_NAME..."
    if curl -f -sS --data "access_token=$LICENSE_KEY" https://plugins.matomo.org/api/2.0/plugins/$PLUGIN_NAME/download/latest?matomo=$MATOMO_CORE_VERSION > plugins-$PLUGIN_NAME.zip; then
        echo "OK"
    else
        echo -e "Please check your Matomo Marketplace license key is correct, and try again." >&2
        exit 1
    fi;
done;

echo -e "Extract all packages in the plugins-downloaded/ directory..."

for PLUGIN_NAME in $PLUGINS_TO_DOWNLOAD
do
    unzip -q -o plugins-$PLUGIN_NAME -d plugins-downloaded/
    rm plugins-$PLUGIN_NAME.zip
done;

echo -e "Done extracting files!\n All plugins packaged in plugins-downloaded/"
