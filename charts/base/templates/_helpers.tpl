{{/*
Common labels for all resources
*/}}
{{- define "workstation.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "workstation.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Namespace for tenant resources
*/}}
{{- define "workstation.tenantNamespace" -}}
{{- printf "%s-%s" .Values.tenant.namespacePrefix .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PostgreSQL connection string
*/}}
{{- define "workstation.postgresUrl" -}}
{{- printf "postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@%s:%d/%s" 
    .Values.services.postgres.host 
    .Values.services.postgres.port 
    .Values.services.postgres.database }}
{{- end }}
