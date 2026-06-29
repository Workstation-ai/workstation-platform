{{/*
Agent full name
*/}}
{{- define "agent.fullname" -}}
{{- printf "%s-agent-%s" .Release.Name .Values.agent.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace for agent
*/}}
{{- define "agent.namespace" -}}
{{- if .Values.namespace.name }}
{{- .Values.namespace.name }}
{{- else }}
{{- printf "agent-%s-%s" .Release.Name .Values.agent.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "agent.labels" -}}
app.kubernetes.io/name: workstation-agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
agent.workstation.io/name: {{ .Values.agent.name }}
agent.workstation.io/user: {{ .Values.agent.userId }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "agent.selectorLabels" -}}
app.kubernetes.io/name: workstation-agent
app.kubernetes.io/instance: {{ .Release.Name }}
agent.workstation.io/name: {{ .Values.agent.name }}
{{- end }}
