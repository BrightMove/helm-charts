{{/*
Container image tag. image.tag overrides Chart.appVersion.
*/}}
{{- define "boiler.imageTag" -}}
{{- default .Chart.AppVersion .Values.image.tag -}}
{{- end -}}

{{/*
Always when the tag is latest, so a retagged latest is pulled. IfNotPresent for any
other tag, so a versioned tag is rolled by changing the pod template. image.pullPolicy
overrides this when set.
*/}}
{{- define "boiler.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{- .Values.image.pullPolicy -}}
{{- else if eq (include "boiler.imageTag" .) "latest" -}}
Always
{{- else -}}
IfNotPresent
{{- end -}}
{{- end -}}

{{/*
PVC mounted at dataDir when persistence is enabled.
*/}}
{{- define "boiler.dataClaim" -}}
{{- default (printf "%s-data" .Release.Name) .Values.persistence.existingClaim -}}
{{- end -}}

{{/*
"true" when persistence is a ReadWriteOnce claim (one node). Empty otherwise.
*/}}
{{- define "boiler.rwoPersistence" -}}
{{- $accessModes := .Values.persistence.accessModes | default (list "ReadWriteOnce") -}}
{{- if and .Values.persistence.enabled (has "ReadWriteOnce" $accessModes) (not (has "ReadWriteMany" $accessModes)) -}}
true
{{- end -}}
{{- end -}}
