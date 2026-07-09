{{- define "gitops-demo-api.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gitops-demo-api.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "gitops-demo-api.labels" -}}
app: {{ include "gitops-demo-api.name" . }}
version: {{ .Chart.AppVersion | quote }}
managed-by: Helm
release: {{ .Release.Name }}
{{- end }}

{{- define "gitops-demo-api.selectorLabels" -}}
app: {{ include "gitops-demo-api.name" . }}
release: {{ .Release.Name }}
{{- end }}
