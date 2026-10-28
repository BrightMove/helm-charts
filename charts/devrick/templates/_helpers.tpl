{{- define "devrick.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{- define "devrick.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "devrick.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: devrick
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "devrick.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Image tags: base target for coordinator/dashboard, "-agent" target for workers. */}}
{{- define "devrick.tag" -}}
{{- default .Chart.AppVersion .Values.image.tag -}}
{{- end -}}

{{- define "devrick.baseImage" -}}
{{- printf "%s:%s" .Values.image.repository (include "devrick.tag" .) -}}
{{- end -}}

{{- define "devrick.agentImage" -}}
{{- printf "%s:%s%s" .Values.image.repository (include "devrick.tag" .) .Values.image.agentTagSuffix -}}
{{- end -}}

{{/* Names of the two credential Secrets (chart-created, or the user's own via existingSecret). */}}
{{- define "devrick.coreSecret" -}}
{{- default (printf "%s-core" (include "devrick.fullname" .)) .Values.secrets.core.existingSecret -}}
{{- end -}}

{{- define "devrick.engineSecret" -}}
{{- default (printf "%s-engine" (include "devrick.fullname" .)) .Values.secrets.engine.existingSecret -}}
{{- end -}}

{{- define "devrick.mcpSecret" -}}
{{- default (printf "%s-mcp" (include "devrick.fullname" .)) .Values.secrets.mcp.existingSecret -}}
{{- end -}}

{{- define "devrick.mcpEnabled" -}}
{{- if or .Values.secrets.mcp.existingSecret .Values.secrets.mcp.json -}}true{{- end -}}
{{- end -}}

{{- define "devrick.configMap" -}}
{{- printf "%s-config" (include "devrick.fullname" .) -}}
{{- end -}}

{{- define "devrick.transcriptsClaim" -}}
{{- if .Values.transcripts.existingClaim -}}
{{- .Values.transcripts.existingClaim -}}
{{- else -}}
{{- printf "%s-transcripts" (include "devrick.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "devrick.workerServiceAccount" -}}
{{- printf "%s-worker" (include "devrick.fullname" .) -}}
{{- end -}}
