{{/*
Desktop full name
*/}}
{{- define "desktop.fullname" -}}
{{- printf "%s-desktop-%s" .Release.Name .Values.desktop.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace for desktop
*/}}
{{- define "desktop.namespace" -}}
{{- if .Values.namespace.name }}
{{- .Values.namespace.name }}
{{- else }}
{{- printf "desktop-%s-%s" .Release.Name .Values.desktop.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "desktop.labels" -}}
app.kubernetes.io/name: workstation-desktop
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
desktop.workstation.io/name: {{ .Values.desktop.name }}
desktop.workstation.io/user: {{ .Values.desktop.userId }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "desktop.selectorLabels" -}}
app.kubernetes.io/name: workstation-desktop
app.kubernetes.io/instance: {{ .Release.Name }}
desktop.workstation.io/name: {{ .Values.desktop.name }}
{{- end }}

{{/*
Generate VNC password if not provided
*/}}
{{- define "desktop.vncPassword" -}}
{{- if .Values.desktop.vnc.password }}
{{- .Values.desktop.vnc.password }}
{{- else }}
{{- randAlphaNum 16 }}
{{- end }}
{{- end }}
