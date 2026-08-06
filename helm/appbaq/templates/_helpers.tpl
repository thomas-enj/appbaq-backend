{{- define "appbaq.name" -}}
{{- include "appbaq.backendName" . | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "appbaq.fullname" -}}
{{- printf "%s" (include "appbaq.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "appbaq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "appbaq.namespaceLabels" -}}
helm.sh/chart: {{ include "appbaq.chart" . }}
app.kubernetes.io/name: {{ .Values.global.namespace }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ index .Values.global.labels "app.kubernetes.io/part-of" | quote }}
environment: {{ .Values.global.labels.environment | quote }}
owner: {{ .Values.global.labels.owner | quote }}
{{- end -}}

{{- define "appbaq.commonLabels" -}}
helm.sh/chart: {{ include "appbaq.chart" . }}
{{ include "appbaq.backendSelectorLabels" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ index .Values.global.labels "app.kubernetes.io/part-of" | quote }}
environment: {{ .Values.global.labels.environment | quote }}
owner: {{ .Values.global.labels.owner | quote }}
{{- end -}}

{{- define "appbaq.backendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "appbaq.name" . }}
app.kubernetes.io/component: backend
{{- end -}}

{{- define "appbaq.backendLabels" -}}
{{ include "appbaq.commonLabels" . }}
{{- end -}}

{{- define "appbaq.backendName" -}}
appbaq-backend
{{- end -}}

{{- define "appbaq.frontendName" -}}
appbaq-frontend
{{- end -}}
