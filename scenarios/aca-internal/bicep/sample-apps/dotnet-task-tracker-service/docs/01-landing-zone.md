# Deploy the landing zone

To deploy the landing zone, you can follow the complete guide in [Azure Container Apps - Internal environment secure baseline [Bicep]](../../../../bicep/README.md).

The deployment of the sample app deploys also an application gateway with the same name as the one of the landing zone. It is recommended to deploy only the first four building blocks of the landing zone and then deploy this sample app, i.e. do not deploy hello world sample app and application gateway. To do so, you can set the attribute `deployHelloWorldSampleApp` to `false` in the parameters file of the landing zone.

To have Dapr observability in Application Insights, you need to set the attributes `enableApplicationInsights` and `enableDaprInstrumentation` to `true` in the parameters file of the landing zone. To know more about monitoring and observability, you can follow this documentation [Operations management considerations for Azure Container Apps](../../../../../../docs/design-areas/management.md).

:arrow_forward: [Deploy Azure Container Apps](./02-container-apps.md)
