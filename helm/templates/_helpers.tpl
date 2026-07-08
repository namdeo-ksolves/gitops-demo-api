{{- define "gitops-demo-api.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gitops-demo-api.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gitops-demo-api.labels" -}}
app: {{ include "gitops-demo-api.name" . }}
release: {{ .Release.Name }}
version: {{ .Chart.AppVersion }}
{{- end }}
