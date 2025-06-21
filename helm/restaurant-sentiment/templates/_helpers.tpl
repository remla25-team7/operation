{{/*
Generate a full name for Helm resources based on release and chart name.
Example output: custom1-restaurant-sentiment
*/}}
{{- define "restaurant-sentiment.fullname" -}}
{{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
