## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```
helm repo add brightmove https://brightmove.github.io/helm-charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo
brightmove` to see the charts.

To install the flat-pdf chart:

```
helm install my-flat-pdf brightmove/flat-pdf
```

To uninstall the chart:

```
helm delete my-flat-pdf
```

## Charts available

- flat-pdf

## Charts in the works

- beancounter
- ats
- ats-ax
- engage
- reports
- email-sync
- cloud-tuner
- jasper
- sourcejet
