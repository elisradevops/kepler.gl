#!/bin/sh
set -eu

target_dir="/usr/share/nginx/html"

replace_placeholder() {
  env_primary="$1"
  env_fallback="$2"
  placeholder="$3"

  value="$(printenv "$env_primary" 2>/dev/null || true)"
  if [ -z "$value" ] && [ -n "$env_fallback" ]; then
    value="$(printenv "$env_fallback" 2>/dev/null || true)"
  fi

  if [ -z "$value" ]; then
    echo "$env_primary is not set; replacing $placeholder with empty string"
  else
    echo "Injecting $env_primary"
  fi

  escaped_value=$(printf '%s\n' "$value" | sed 's/[&|]/\\&/g')

  find "$target_dir" -type f \( -name '*.js' -o -name '*.css' -o -name '*.html' \) \
    -exec sed -i "s|$placeholder|$escaped_value|g" {} +
}

replace_placeholder "MAPBOX_ACCESS_TOKEN" "MapboxAccessToken" "__MAPBOX_ACCESS_TOKEN__"
replace_placeholder "DROPBOX_CLIENT_ID" "DropboxClientId" "__DROPBOX_CLIENT_ID__"
replace_placeholder "MAPBOX_EXPORT_TOKEN" "MapboxExportToken" "__MAPBOX_EXPORT_TOKEN__"
replace_placeholder "CARTO_CLIENT_ID" "CartoClientId" "__CARTO_CLIENT_ID__"
replace_placeholder "FOURSQUARE_CLIENT_ID" "FoursquareClientId" "__FOURSQUARE_CLIENT_ID__"
replace_placeholder "FOURSQUARE_DOMAIN" "FoursquareDomain" "__FOURSQUARE_DOMAIN__"
replace_placeholder "FOURSQUARE_API_URL" "FoursquareAPIURL" "__FOURSQUARE_API_URL__"
replace_placeholder "FOURSQUARE_USER_MAPS_URL" "FoursquareUserMapsURL" "__FOURSQUARE_USER_MAPS_URL__"

echo "Starting nginx"
exec nginx -g "daemon off;"
