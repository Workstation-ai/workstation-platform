{{/*
Desktop full name
*/}}
{{- define "desktop.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.desktop.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace for desktop
*/}}
{{- define "desktop.namespace" -}}
{{- if .Values.namespace.name }}
{{- .Values.namespace.name }}
{{- else }}
{{- .Release.Namespace }}
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

{{/*
Resource profile resolution:
  small  = 250m/256Mi request, 1/1Gi limit
  medium = 500m/512Mi request, 2/2Gi limit
  large  = 1/1Gi request,     4/4Gi limit
*/}}
{{- define "desktop.resources" -}}
{{- $profile := .Values.desktop.profile | default "" -}}
{{- if eq $profile "large" }}
requests:
  cpu: "1"
  memory: "1Gi"
limits:
  cpu: "4"
  memory: "4Gi"
{{- else if eq $profile "medium" }}
requests:
  cpu: "500m"
  memory: "512Mi"
limits:
  cpu: "2"
  memory: "2Gi"
{{- else }}
{{- /* small or unset — use explicit values or defaults */ -}}
{{- if .Values.desktop.resources }}
{{- toYaml .Values.desktop.resources | nindent 0 }}
{{- else }}
requests:
  cpu: "250m"
  memory: "256Mi"
limits:
  cpu: "1"
  memory: "1Gi"
{{- end }}
{{- end }}
{{- end }}
