# Deploy the Landing Zone

To deploy the Landing Zone, you can follow the complete guide in [Enterprise Scale for ACA - Private](../../../../bicep/README.md).

The deployment of the sample app deploys also an application gateway with the same name as the one of the landing zone. It is recommended to deploy only the first four building blocks of the landing zone and then deploy the sample app, i.e. do not deploy hello world sample app and application gateway. To do so, you can set the attribute `deployHelloWorldSampleApp` to `false` in the parameters file of the landing zone.

:arrow_forward: [Deploy Container Apps](./02-container-apps.md)
