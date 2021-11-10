# Continuous verification of security components using a CI/CD pipeline.
This repository contains an example to use pipelines as a solution to continuously verify different configuration for a secure infrastructure.

This repository is the result from a use-case-driven-paper for the postgraduate degree Advanced Cybersecurity Professional, Howest, Belgium.

**Use Case**

A growing MSSP is often expected to monitor and maintain the complete infrastructure of a customer. They often believe that their current situation is correctly configured and is protecting them from outside threats. During the product/solution lifecycle a lot of changes happen to the configuration either by the MSSP, the customer or other (malicious) actors. To answer these possible risks and expectations a proof of concept has been defined using the automation possibilities found in pipelines. Implementation of the pipeline should use a key management solution to securely handle customer credentials.

The pipeline should monitor the following aspects of the infrastructure of a small and midsize business (SMB), as visualized in Figure 1.
1.	Inbound ports should be monitored to verify changes in the public facing attack surface. Additionally public faced vulnerabilities should be identified.
2.	Outbound traffic possibilities should be monitored as well as the effectiveness of the security services on a firewall.
3.	Configuration of an Azure Active Directory (AAD) and other M365 solutions to identity if best-practices are configured.
4.	Configuration of Active Directory (AD) to identify if best practices are configured. These configurations should be verified using a reference host.

![image](https://user-images.githubusercontent.com/6162251/140816356-08d96186-b76a-478d-8fd6-df3962f1b2bc.png)
