# SA Coach Studio export

Exported 24 Nov 2026, 2:50 pm. Contains every level's brief, checklist, notes, customer/interviewer chat, tutor chat and score.

## Scores

| Level | Requirements | Architecture | Security | Cost | Resilience | Communication | Overall | Top gap |
|---|---|---|---|---|---|---|---|---|
| L3 | 6 | 6 | 6 | 5 | 3 | 3 | 4.5 | Answer with finished numbers and specifics: about $24/month for 3 endpoints in 1 AZ, about $48 in 2 AZs, about $82 for 2 NATs before data. Name the status values (Online / ConnectionLost) and the errors (TargetNotConnected). Explain the hourly break-even of about 5 interface endpoints per AZ versus one NAT, and the per-GB gap of about $0.056 for NAT versus about $0.01 for endpoints. |

## Cost log (estimates)

- Level 1: 20 Nov 2026, 8:34 pm to 20 Nov 2026, 8:34 pm, about $0
- Level 2: 21 Nov 2026, 12:40 am to 21 Nov 2026, 12:42 am, about $0


---

## Level 0: Account safety + Terraform setup

Phase: clarify. Hints used: 2.

**Requirements**
- Turn on MFA for the root user, then stop using root
- Create an IAM user for yourself with admin access and MFA
- Create a $5 monthly budget with an email alert
- Install AWS CLI v2 and Terraform; set default region ap-south-1
- Write a tiny Terraform file (e.g. one S3 bucket) and run init → plan → apply → destroy

**Constraints**
- Never create access keys for root
- Free plan account: do not touch AWS Organizations or Control Tower

**Acceptance tests**
- [x] Root has MFA (IAM → Security recommendations shows green)
- [x] aws sts get-caller-identity shows your IAM user ARN, not root
- [x] Budget exists and the alert email is confirmed
- [x] terraform -version and aws --version both work
- [x] terraform apply created a bucket and terraform destroy removed it

### Customer and interviewer chat

**Interviewer** (18 Nov 2026, 9:09 pm)

Switching to **interviewer** mode.

Walk me through:
1. Your architecture (what you built and why)
2. The hardest problems you hit and how you fixed them
3. What it cost and how you kept it low

Then I'll ask **4 questions**, one at a time.

---

**You** (20 Nov 2026, 8:32 pm)

bucket thing is done

---

**Coach** (20 Nov 2026, 8:32 pm)

Nice work, that's the full init → plan → apply → destroy loop. 🎉

**Quick self-check before you close Level 0:**
- `terraform destroy` finished with "Destroy complete", and `aws s3 ls` shows no leftover demo bucket.
- `aws sts get-caller-identity` shows `user/...`, not `root`.
- Your `.gitignore` covers `.terraform/` and `*.tfstate*`, and no access keys are in any `.tf` file.
- The budget alert email is confirmed.

If all four are true, your checklist is honest and Level 0 is complete. Cost so far is about $0.

I'm not sure the earlier "interviewer mode" message belongs here. This level has no interview step, so ignore it for now. Mock interview practice makes more sense once you've built a few things.

If you want to understand why Terraform keeps a state file, or what `plan` is really comparing, ask in the **Tutor pane**. It can go into much more detail than I can here.

When you're ready, move on to Level 1.

---

**You** (20 Nov 2026, 8:32 pm)

yes let's move to next level

---

**Coach** (20 Nov 2026, 8:32 pm)

Great, Level 0 is done. 🎉

**Before you click through to Level 1:**
- Confirm nothing is left running (`aws s3 ls` should show no demo bucket). Cost so far: about $0.
- Keep your Terraform folder out of Git, or make sure `.gitignore` is in place first.
- Keep using your IAM user, never root.

**Reminder for the rest of the course:** build, test, then `terraform destroy` the same day. Things like NAT Gateways, load balancers, and RDS are what quietly burn credits, so I'll flag them if they come up.

**What to expect:** Level 1 builds on what you just practiced, using Terraform to create real AWS resources, one small piece at a time. The Level 1 brief will list the exact requirements and costs when you open it.

If a concept feels fuzzy (state files, what `plan` compares, IAM basics), the **Tutor pane** is the place for a detailed walkthrough. Otherwise, open the Level 1 brief and start when you're ready. 🚀

### Tutor chat

**You** (18 Nov 2026, 9:24 pm)

Install AWS CLI v2 and Terraform; set default region ap-south-1

---

**Tutor** (18 Nov 2026, 9:24 pm)

**Cost:** Free (installing tools and setting a region costs nothing).

Quick note: the interviewer message in the side pane doesn't apply yet. Level 0 has no customer, so you can ignore it for now.

**1. Install AWS CLI v2**
- macOS: `brew install awscli`, or use the official .pkg installer
- Windows: `winget install Amazon.AWSCLI`, or use the MSI installer
- Linux: download the zip from the docs and run `sudo ./aws/install`
- Check it: `aws --version` (should say `aws-cli/2.x`)
- Docs: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

**2. Install Terraform**
- macOS: `brew tap hashicorp/tap && brew install hashicorp/tap/terraform`
- Windows: `winget install Hashicorp.Terraform`
- Linux: use HashiCorp's apt/yum repo
- Check it: `terraform -version`

**3. Connect the CLI to your IAM user (not root)**
- In the console, open IAM → Users → your user → Security credentials → Create access key (choose "CLI" as the use case).
- Run `aws configure` and enter:
  - Access key ID and secret key
  - Default region: `ap-south-1`
  - Output format: `json`
- Verify with `aws sts get-caller-identity`. The ARN should end in `user/<your-name>`, not `root`. This is also your second checklist tick.

⚠️ Stop if you're tempted to:
- Create access keys for the root user. Never do this.
- Paste keys into `.tf` files or commit them to Git. The credentials live in `~/.aws/credentials`, and Terraform picks them up automatically.
- Commit `*.tfstate` or `.terraform/` to Git. Add them to `.gitignore` now.

**4. Set the region in Terraform too**
The CLI default and the Terraform provider region are separate settings. Set the region explicitly in your code:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

Provider docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

**Check yourself:**
- `aws --version` and `terraform -version` both print versions.
- `aws configure get region` prints `ap-south-1`.
- `aws sts get-caller-identity` shows your IAM user ARN.

**SAP-C03 relevance:** Know that long-lived IAM user keys are the weaker option. In real multi-account setups you'd use IAM Identity Center or roles with temporary credentials. We'll get there at a later level, since it needs Organizations.

Once these checks pass, the next small piece is the `terraform` block that pins the AWS provider version. Want to try writing it yourself first?

---

**You** (18 Nov 2026, 9:27 pm)

where on my local comuter or on aws where

---

**Tutor** (18 Nov 2026, 9:27 pm)

**On your local computer.** Both tools run on your laptop. Nothing gets installed on AWS.

**Where each piece lives**
- **AWS CLI and Terraform:** installed on your laptop (any terminal: Terminal on macOS, PowerShell on Windows, bash on Linux).
- **Your credentials:** saved on your laptop by `aws configure`, in `~/.aws/credentials` (Windows: `C:\Users\<you>\.aws\credentials`). The default region goes in `~/.aws/config`.
- **Your Terraform files:** a normal folder on your laptop, e.g. `~/tf-level0/` containing `main.tf`. Run `terraform init/plan/apply/destroy` from inside that folder.
- **On AWS:** only the things Terraform creates (e.g. the S3 bucket) and your IAM user. The tools talk to AWS over the internet using your access key.

**Mental model:** your laptop sends API calls to AWS, and AWS builds the resources. Terraform also writes a `terraform.tfstate` file in your project folder on your laptop. Keep it out of Git.

**Cost:** Free. Installing tools and running them locally costs nothing. Only the resources they create can be billed, and the S3 bucket in this level is effectively $0 while empty.

**Optional alternative:** AWS CloudShell (the terminal icon in the console) already has the CLI preinstalled and is free. But for this learning path, set up your laptop, since that's where you'll work every level.

**SAP-C03 relevance:** In real teams, Terraform often runs from a CI/CD pipeline with a role and remote state (S3 + locking) instead of a laptop. We'll cover that later.

Next step: make the folder, e.g. `mkdir tf-level0 && cd tf-level0`, then install the two tools there in your terminal. Tell me which OS you're on if you hit any snags.

---

**You** (18 Nov 2026, 9:31 pm)

PS C:\Users\asgha\Desktop\AWS> aws update
aws : The term 'aws' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the
spelling of the name, or if a path was included, verify that the path is correct and try again.
At line:1 char:1
+ aws update
+ ~~~
    + CategoryInfo          : ObjectNotFound: (aws:String) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : CommandNotFoundException

PS C:\Users\asgha\Desktop\AWS>




also which model you are using use sonnet 5.5

---

**Tutor** (18 Nov 2026, 9:31 pm)

**Cost:** Free.

**Cause:** PowerShell can't find a program called `aws`. Either the AWS CLI isn't installed yet, or it is installed but your terminal hasn't picked up the new PATH. Also, `aws update` isn't a real AWS CLI command, so use `aws --version` to test.

**Fix (Windows):**
1. Install it with one of these:
   - `winget install Amazon.AWSCLI`
   - Or download the MSI from https://awscli.amazonaws.com/AWSCLIV2.msi and run it.
2. **Close PowerShell completely and open a new window.** PATH changes only apply to new terminals.
3. Run `aws --version`. You should see something like `aws-cli/2.x ...`.

**If it's still not found:**
- Run `where.exe aws`. It should print `C:\Program Files\Amazon\AWSCLIV2\aws.exe`.
- If the file exists but isn't found, add `C:\Program Files\Amazon\AWSCLIV2\` to your PATH (Start → "Edit the system environment variables" → Environment Variables → Path → New), then reopen PowerShell.

**Terraform on Windows:** `winget install Hashicorp.Terraform`, then reopen PowerShell and run `terraform -version`.

**About the model:** I can't switch models from here, and I don't know which specific version is running this app. I'm Claude, and I'll keep helping with your Level 0 setup.

Once `aws --version` works, the next step is `aws configure` with your IAM user's key (never root), then `aws sts get-caller-identity`. Paste the output here if anything looks off, but never paste your secret key.

---

**You** (18 Nov 2026, 9:32 pm)

I actually installed with 
irm https://awscli.amazonaws.com/v2/install.ps1 | iex

---

**Tutor** (18 Nov 2026, 9:32 pm)

**Cost:** Free.

⚠️ Stop: I don't recognize `install.ps1` at that URL as an official, documented AWS CLI installer. The AWS docs for Windows list only the MSI, either by download or from the command line. Piping a downloaded script into `iex` runs whatever it contains, so avoid that pattern unless the source is documented. I can't verify what that script did on your machine.

**Check what happened:**
1. Close PowerShell and open a new window, so any PATH change applies.
2. Run `aws --version`.
3. Run `where.exe aws`.

**If both work:** the CLI is installed. To be safe, check that the path looks like `C:\Program Files\Amazon\AWSCLIV2\aws.exe`. If it points somewhere unexpected, reinstall using the official method below.

**If the command is still not found (likely, given your earlier error):** use the official installer:
- `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi`
- Or `winget install Amazon.AWSCLI`
- Docs: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Then open a new PowerShell and run `aws --version` again.

**Good habit:** only run install commands from the vendor's official docs. This matters more once you hold AWS credentials on the machine.

Paste the output of `aws --version` and `where.exe aws` here, and we'll move on to `aws configure` with your IAM user (never root).

---

**You** (18 Nov 2026, 9:33 pm)

done now teraform

---

**Tutor** (18 Nov 2026, 9:33 pm)

**Cost:** Free.

**Install Terraform on Windows**
1. In PowerShell, run: `winget install Hashicorp.Terraform`
2. **Close PowerShell and open a new window** so the PATH updates.
3. Run `terraform -version`. You should see something like `Terraform v1.x.x`.

**If winget isn't available or the command isn't found:**
- Download the Windows AMD64 zip from https://developer.hashicorp.com/terraform/install
- Unzip it to a folder like `C:\terraform\` (you'll get `terraform.exe`)
- Add that folder to PATH (Start → "Edit the system environment variables" → Environment Variables → Path → New), then reopen PowerShell.
- Check with `where.exe terraform`.

**Before moving on, confirm the AWS side too:**
- `aws --version` works
- `aws configure get region` prints `ap-south-1`
- `aws sts get-caller-identity` shows `user/<your-name>`, not `root`

If `aws configure` isn't done yet, create the access key for your **IAM user** (never root), run `aws configure`, and never paste the secret key here or into any `.tf` file.

**Project folder and .gitignore (do this now):**
```powershell
cd C:\Users\asgha\Desktop\AWS
mkdir tf-level0
cd tf-level0
```
Create a `.gitignore` containing:
```
.terraform/
*.tfstate
*.tfstate.*
```

**Next small piece (your turn):** write a `main.tf` with just a `terraform` block that requires the `hashicorp/aws` provider (version `~> 6.0`), plus the `provider "aws"` block with `region = "ap-south-1"`. Then run `terraform init`. Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Paste the output of `terraform -version` and, after that, `terraform init` if you hit any errors.

**SAP-C03 relevance:** Infrastructure as code (Terraform, CloudFormation) is central to the "operational excellence" and "deployment strategy" domains, so being comfortable with the init → plan → apply → destroy loop pays off later.

---

**You** (18 Nov 2026, 11:39 pm)

what is terraform

---

**Tutor** (18 Nov 2026, 11:39 pm)

**Cost:** Free (the tool itself costs nothing; only the AWS resources it creates can be billed).

**Terraform in one line:** a tool that lets you describe your cloud infrastructure in text files, then builds it for you.

**The idea (infrastructure as code):**
- Instead of clicking in the AWS console, you write what you want, e.g. "one S3 bucket in Mumbai".
- Terraform calls the AWS APIs and creates it.
- The files can be versioned in Git, reviewed, and reused, so builds are repeatable.

**The four commands you'll use:**
- `terraform init`: downloads the AWS provider plugin (the part that knows how to talk to AWS).
- `terraform plan`: shows what it *would* create, change, or delete. Nothing happens yet.
- `terraform apply`: actually creates the resources.
- `terraform destroy`: deletes everything it created, which is how you keep costs near zero.

**Key pieces:**
- **Provider:** the plugin for a platform (AWS here).
- **Resource:** one thing to build, like a bucket or a VM.
- **State file (`terraform.tfstate`):** Terraform's record of what it built. It lives on your laptop. Keep it out of Git.

**Tiny example (one concept: a resource):**
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-unique-demo-bucket-12345"
}
```
This says: "I want an S3 bucket with this name." Bucket names must be globally unique, so change the number part.

**Terraform vs the console:**
- Console: fast to try, hard to repeat, easy to forget what you made.
- Terraform: repeatable, reviewable, and easy to tear down.

**Related AWS service:** CloudFormation does the same job but is AWS-only and uses JSON/YAML. Terraform works across many clouds.

**SAP-C03 relevance:** exam questions often favor infrastructure as code (CloudFormation on the exam) for consistent, repeatable deployments. Terraform uses the same mindset.

Next: confirm `terraform -version` works in a new PowerShell window. Paste the output if it doesn't.


---

## Level 1: One web server (EC2 + nginx)

Phase: review. Hints used: 3.

**Customer:** Ravi Kulkarni, Owner, Chai Point, Pune

> I run a small chai café in Kothrud, Pune. I just want a simple page on the internet that says 'Chai Point – Open 7am–10pm' with our menu. It must be cheap, and I don't want hackers getting in.

**Requirements**
- A web page reachable from a browser
- Built by hand in the AWS Console first; rebuilt in Terraform afterwards
- Only web traffic is allowed in
- Costs ₹0

**Constraints**
- Region ap-south-1 (Mumbai)
- Instance type t3.micro (free tier)
- Default VPC is fine at this level
- Tag every resource Project=aws-practice
- Cost cap: $0.50 for the whole exercise

**Acceptance tests**
- [x] The instance's public IP opens in a browser and shows the Chai Point page
- [x] Security Group allows only port 80 inbound, with no port 22
- [x] Page content comes from user data (no manual login to the server)
- [x] curl -i http://<public-ip> returns HTTP 200
- [x] Instance terminated; describe-instances, describe-volumes and describe-addresses show nothing left

**Customer facts (hidden during the exercise)**
- traffic: About 150–200 visitors a day, mostly people near Kothrud checking timings on their phones.
- uptime: If it is down for an hour at night that's okay. During morning rush (7–10am) it should be up.
- content: Name, timings 7am–10pm, a short menu: cutting chai ₹15, masala chai ₹20, bun maska ₹30, poha ₹40. Phone number 98xxxxxx21.
- updates: My nephew Aditya might change the menu once a month. He knows a little computer stuff.
- https: I don't know what HTTPS is. Whatever is free is fine for now.
- domain: Later I may buy chaipoint-pune.in, not now.
- data: No customer data, no login, no payments. Just information.
- admin: Nobody should log into the server. If something changes, just rebuild it.
- budget: Zero rupees. If anything will cost money, tell me before you do it.

### Customer and interviewer chat

**You** (20 Nov 2026, 8:33 pm)

I can understand your requirment I'll suggest you s3 with cloudfront

---

**Ravi Kulkarni** (20 Nov 2026, 8:33 pm)

Arrey, S3 and CloudFront? These are big words for me, ji. I only know I want a simple page showing our timings and menu, and I can't spend even one rupee. Will this cost anything? If yes, please tell me before you do it.

Also, do you want to ask me anything more about the café, like how many people visit or when it must be working? That will help you understand what I need.

---

**You** (20 Nov 2026, 8:35 pm)

how many customers visit your shop and is it static website or any dynamic content is there

---

**Ravi Kulkarni** (20 Nov 2026, 8:35 pm)

Good questions, ji! About 150–200 people visit the page every day, mostly folks around Kothrud checking our timings on their phones.

And it is only information: our name, timings 7am–10pm, and a short menu (cutting chai ₹15, masala chai ₹20, bun maska ₹30, poha ₹40) with our phone number. No login, no payments, no customer details. My nephew Aditya may change the menu once a month, that's all.

---

**You** (20 Nov 2026, 8:36 pm)

Okay understood I think we have use the website build and direclty host that in S3 bucket bascially it is kind of data store and we point users to that store that will be easy thing to do

---

**Ravi Kulkarni** (20 Nov 2026, 8:37 pm)

⚠️ Stop: A "data store" that every visitor can open directly means making it public to the whole internet, and that is exactly the kind of thing I'm worried about. A public bucket is a common way for things to go wrong. The safer, cheaper route for this exercise is the one in my brief: one small t3.micro server, with only web traffic allowed in. That is about $0 on the free tier, and well under your $0.50 cap even with a few hours of testing.

Honestly, ji, I don't understand these technical things. I only know I asked for one simple web server, built and deleted with a single command each. If you feel strongly about another approach, please check with your tutor first. Is there anything else about the café you want to ask me before you start?

---

**You** (20 Nov 2026, 8:40 pm)

understood I'll create one Ec2 instance with public restricted access only though our public IP and EBS 8GB gp3

---

**Ravi Kulkarni** (20 Nov 2026, 8:40 pm)

Wah, that sounds like what I asked for, ji. One server, only web visitors allowed in, and nothing that costs me money. If anything will cost even a rupee, please tell me first, okay?

I don't understand the technical parts, so I'll trust you on those. One thing I do care about is that after your testing, everything should be fully removed so no bill comes later. Anything else you want to ask about the café before you start?

---

**You** (20 Nov 2026, 8:53 pm)

do you have webiste page with you

---

**Ravi Kulkarni** (20 Nov 2026, 8:53 pm)

No ready-made page, ji. I only have the details, so please make a simple one for me:

- **Name:** Chai Point, Kothrud, Pune
- **Timings:** 7am to 10pm
- **Menu:** cutting chai ₹15, masala chai ₹20, bun maska ₹30, poha ₹40
- **Phone:** 98xxxxxx21

Nothing fancy is needed. I just want people to see "Chai Point – Open 7am–10pm" and the menu clearly on their phones. Later my nephew Aditya may change the prices once a month.

---

**You** (20 Nov 2026, 8:53 pm)

in which region you want to host it

---

**Ravi Kulkarni** (20 Nov 2026, 8:53 pm)

Region-bit I don't understand, ji, but all my customers are here in Pune. So whatever is closest to us, Mumbai side, would be best so the page opens fast on their phones. And please remember, no extra cost without telling me first!

---

**Interviewer** (20 Nov 2026, 10:09 pm)

Switching to **interviewer** mode.

Walk me through:
1. Your architecture (what you built and why)
2. The hardest problems you hit and how you fixed them
3. What it cost and how you kept it low

Then I'll ask **4 questions**, one at a time.

---

**Coach** (20 Nov 2026, 10:09 pm)

**[Coach]**

Your best question was asking whether the site is static or has dynamic content. It settled the whole design: information only, no logins, no data.

**Important questions you missed:**

1. **How much downtime is acceptable, and when?** This sets the availability target. Ravi said an hour at night is fine, but the 7-10am rush must be up. That tells you one instance is enough, with no load balancer or Multi-AZ, and it keeps cost at zero.
2. **How often does the content change, and who changes it?** Aditya edits the menu about once a month and knows "a little computer stuff". This decides how updates happen. If nobody should log in to the server, the answer is to change user data and rebuild, not SSH in.
3. **Is HTTPS needed, and do you have a domain?** Ravi doesn't know what HTTPS is, wants whatever is free, and may buy chaipoint-pune.in later. Plain HTTP on port 80 fits level 1, but you should note the trade-off. A domain and a certificate belong in a later design, and you should tell him it will cost money before you build it.
4. **Does anyone need to log in to the server?** Ravi said no, and that "if something changes, just rebuild it". This is why port 22 is not needed. User data is the only way the page gets onto the server, and Terraform makes the rebuild repeatable.
5. **What is the exact budget and who approves spending?** Ravi said zero rupees and to be told before anything costs money. Confirm the free-tier limits, the $0.50 cap, and the same-day cleanup.

**Also note:** you called a public S3 bucket "easy", and I stopped you. Keep to the brief for this level: EC2 with nginx, port 80 only, Project=aws-practice tags, and nothing left running.

**Next:** build the instance with user data and a port-80-only Security Group. Then launch a fresh instance without logging in to prove the page comes from user data, and run `curl -i` for a 200.


---

## Level 2: Your own VPC

Phase: review. Hints used: 0.

**Customer:** Meghna Rathore, Co-founder & Head of Operations, Kesari Handlooms Pvt. Ltd. (Jaipur, Rajasthan)

> We sell hand-block-printed sarees and home textiles from about 140 artisan families around Sanganer, mostly to customers in India and some in the UK. Last year a freelancer put our website and our order database on AWS in the default network, and a few weeks ago our hosting audit showed the database port was reachable from the whole internet. Nobody was breached, but it scared us badly. Before we move anything else, I want a proper network of our own: public-facing parts clearly separated from private parts, locked down, able to survive one data centre going down, and not costing us money for things we don't use yet.

**Requirements**
- Create a dedicated network (VPC) for Kesari Handlooms with an IP range that won't clash with our office network or with the other networks we plan to add later.
- Build a public layer for the future website and a private layer for the future database and order system. Spread both layers across two Availability Zones so that losing one zone doesn't take everything down. Only the public layer may have a direct route to and from the internet.
- The public layer should accept normal web traffic from customers. Only our own team should be able to get in for administration, and nothing in the private layer should ever be reachable from the internet.
- Add a second, subnet-level layer of protection on the private layer, in addition to the per-server firewall rules, and be ready to explain to me how the two layers differ.
- Keep running costs at essentially zero: no paid networking components that we don't need today, nothing left behind after testing, and every resource tagged Project=aws-practice so leftovers can be found.

**Constraints**
- Build everything by hand in the AWS Management Console first, verify it with the AWS CLI, then delete it all the same day. Afterwards, rebuild it in Terraform (time-box about 1 hour) and destroy that too.
- Region: ap-south-1 (Mumbai) only. Use two AZs, e.g. ap-south-1a and ap-south-1b.
- Total cost cap for the whole exercise: USD 1.00, assuming you build, test and destroy in one sitting.
- If you launch a test instance, use only Free-plan-eligible types (t3.micro or t2.micro) with Amazon Linux 2023. Run at most 1–2 instances, and terminate them within the session.
- No NAT Gateway, no VPC endpoints, no Transit Gateway, no VPN, and no Elastic IPs. The private subnets do not need outbound internet at this level.
- No SSH open to 0.0.0.0/0. Do not use root access keys. Use an IAM user or role with MFA.
- Do not use AWS Organizations, Control Tower or Direct Connect.
- Tag every resource (VPC, subnets, IGW, route tables, NACL, security groups, any instance) with Project=aws-practice and a Name tag.

**Acceptance tests**
- [x] aws ec2 describe-vpcs --region ap-south-1 --filters Name=tag:Project,Values=aws-practice returns exactly one VPC, with the agreed CIDR (not overlapping 192.168.1.0/24 or 10.1.0.0/16).
- [x] aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=<vpc-id> returns 4 subnets: 2 public and 2 private, with one of each in ap-south-1a and one of each in ap-south-1b. Only the public subnets show MapPublicIpOnLaunch=true.
- [x] aws ec2 describe-route-tables --region ap-south-1 --filters Name=vpc-id,Values=<vpc-id> shows a public route table with 0.0.0.0/0 -> igw-xxxx, associated with both public subnets. It also shows a private route table with only the 'local' route, associated with both private subnets.
- [x] aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=<vpc-id> shows exactly one IGW, in state 'available'.
- [x] aws ec2 describe-security-groups --filters Name=vpc-id,Values=<vpc-id> shows: the web SG allows 80/443 from 0.0.0.0/0; no SG allows port 22 from 0.0.0.0/0; the private SG allows inbound only from the web SG (by SG reference, not by CIDR).
- [x] aws ec2 describe-network-acls --filters Name=vpc-id,Values=<vpc-id> shows a custom NACL associated with both private subnets. It has explicit inbound allow rules from the VPC CIDR only, plus outbound rules covering ephemeral ports 1024-65535.
- [x] Optional live test: a t3.micro in a public subnet serves a test page (curl http://<public-ip> from your laptop works). A t3.micro in a private subnet has no public IP and cannot be reached from the internet. Then terminate both.
- [x] Clean delete: after teardown, these all return empty results for the region: aws ec2 describe-instances --filters Name=instance-state-name,Values=running,stopped; aws ec2 describe-vpcs --filters Name=tag:Project,Values=aws-practice; aws ec2 describe-addresses; aws ec2 describe-nat-gateways --filter Name=state,Values=available.

**Customer facts (hidden during the exercise)**
- admin_access: 'Only our team' means our two developers, Arjun and Farhan. They work from the Jaipur office, whose static public IP is 203.0.113.25. Ideally no one SSHes at all. If SSH is needed, allow it only from that /32, or use EC2 Instance Connect or Session Manager instead.
- budget: Our whole AWS budget is around ₹8,000 (about $95) a month for production. I don't want to pay for networking that sits idle.
- data_sensitivity: The database will hold customer names, phone numbers and delivery addresses. That's personal data under India's DPDP Act, so it must never be publicly reachable. Payments go through Razorpay, so we don't store card data.
- future_networks: Next year we want a separate staging network, and our IT vendor has already reserved 10.1.0.0/16 for it. So this production network should be 10.0.0.0/16, with /24 subnets.
- growth: We expect roughly 2x orders within 18 months, as we start selling on our own site instead of only through marketplaces.
- office_network: Our Jaipur office router uses 192.168.1.0/24. Please don't overlap that, because we may connect the office to AWS with a VPN one day.
- private_internet_need: The private layer doesn't need to reach the internet right now. Later the order system will need to call Razorpay and Shiprocket APIs, but we'll solve that when we get there, cheaply.
- resilience: If one data centre fails, we can accept the site being degraded for up to 1 hour (RTO). We can lose at most 15 minutes of orders (RPO). That's why we want two zones from the start.
- team_skills: Arjun knows Linux and PHP, Farhan knows React. Neither has managed AWS networking, so please keep the design simple and well-named.
- traffic: About 2,000 visitors a day normally, rising to 15,000 a day during Diwali and wedding season (October–December). 85% are from India, mainly Delhi NCR, Mumbai and Bengaluru, and the rest are from the UK.

### Customer and interviewer chat

**You** (20 Nov 2026, 10:16 pm)

first I'll like to know what is your current setup

---

**Meghna Rathore** (20 Nov 2026, 10:16 pm)

Last year a freelancer put our website and our order database on AWS, all in the "default network", as he called it. I don't know the technical details, honestly. A few weeks ago our hosting audit showed that the database port could be reached from the whole internet, and that really scared us. Nobody got in, thankfully, but I don't want to move anything else until we have a proper, safe setup of our own.

---

**You** (20 Nov 2026, 10:21 pm)

what are public facing parts here and do you have elastic IP or what

---

**Meghna Rathore** (20 Nov 2026, 10:21 pm)

The public-facing part is just our website, the pages customers open to browse sarees and place orders. The database and the order system should stay hidden from the public. About an Elastic IP, I honestly don't know what the freelancer set up, that's his department. For the new setup I don't want to pay for anything fancy that sits idle, so if you think we need one, please tell me why and what it costs.

---

**Coach** (21 Nov 2026, 12:40 am)

**[Coach]**

Your best question was asking what the public-facing parts are and whether an Elastic IP is in use, because it pinned down what must be public versus private and tested the no-idle-cost rule.

Here are the important questions you missed:

1. **Admin access:** Who exactly needs to administer the servers, and from where? This decides the SSH rule (no 0.0.0.0/0) and whether you restrict to a single office /32 or skip SSH entirely with Session Manager or Instance Connect.
2. **Office network and future networks:** What IP ranges does the office use, and what other networks are planned? The VPC CIDR must not overlap the office (192.168.1.0/24) or the reserved staging range (10.1.0.0/16). Your 10.20.0.0/16 is safe, but you chose it without asking.
3. **Resilience targets (RTO/RPO):** How long can the site be degraded, and how much data can be lost? This justifies two AZs from day one and shapes later database choices.
4. **Budget and growth:** What is the monthly AWS budget, and how much growth is expected? This sizes your subnets (/24 gives about 251 usable IPs per subnet) and confirms that NAT Gateway at about $41/month is not justified yet.
5. **Private layer internet needs:** Will the private layer ever need to call external APIs, like payment or shipping? This confirms that no outbound route is fine today, and flags a later cost decision.

Also, you said "I'll delete everything now" before the checklist was complete. Before tearing down, finish the tag fixes, confirm the private-rt associations and subnet flags, and verify the security group and NACL items. Then delete.

**Build next:** finish the verification of route tables and subnets, then create the web and private security groups and the custom NACL on the private subnets, run the CLI checks, and only then tear down.

---

**Interviewer** (21 Nov 2026, 12:40 am)

Switching to **interviewer** mode.

Walk me through:
1. Your architecture (what you built and why)
2. The hardest problems you hit and how you fixed them
3. What it cost and how you kept it low

Then I'll ask **4 questions**, one at a time.

### Tutor chat

**You** (20 Nov 2026, 10:16 pm)

for this test I will need default setup give me quick guide to first create so scenario will play correctly

---

**Tutor** (20 Nov 2026, 10:17 pm)

## You don't need to create a "default setup"

Your AWS account already has a **default VPC** in ap-south-1 (unless someone deleted it). It's the "default network" the freelancer used, and it's free to look at.

⚠️ Stop: don't recreate the customer's mistake (a database port open to 0.0.0.0/0), even as a demo. Just inspect the default VPC read-only and compare it with what you'll build.

## Quick look at the default VPC (free, 2 min)

```bash
aws ec2 describe-vpcs --region ap-south-1 --filters Name=isDefault,Values=true
aws ec2 describe-subnets --region ap-south-1 --filters Name=default-for-az,Values=true \
  --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch}"
```

What to notice:
- CIDR is usually `172.31.0.0/16`.
- One subnet per AZ, **all public** (auto-assign public IP is on, routed to an IGW).
- There is no private layer, so anything launched there is one security group mistake away from the internet. That's the customer's problem.

Don't modify or delete the default VPC. Build your own next to it.

**Cost: $0.** VPCs, subnets, route tables, IGWs, SGs and NACLs are all free.

## Outline for Level 2 (console first)

1. Pick a CIDR for the VPC.
2. Create the VPC (tag `Project=aws-practice` + `Name`).
3. Create 4 subnets: public and private in each of 1a and 1b.
4. Create and attach an IGW.
5. Create a public route table (`0.0.0.0/0` → IGW) and a private one (local only), then associate them.
6. Create the web SG and private SG (reference the web SG, not a CIDR).
7. Create a custom NACL for the private subnets.
8. Verify with the CLI, run an optional live test, and delete everything.

## Your next small piece: choose the CIDR

The customer's brief says it must not clash with the office network or with future networks. Check the checklist for the ranges you know to avoid, and think about:
- `/16` gives about 65k addresses. How many do you actually need?
- How would you carve four non-overlapping `/24` subnets out of your VPC range?
- Which ranges are already taken, so which first octets and second octets are unsafe?

Reply with your proposed VPC CIDR and your four subnet CIDRs, and I'll sanity-check them.

*SAP-C03 relevance: non-overlapping CIDR planning is the foundation for peering, Transit Gateway and hybrid connectivity questions.*

---

**You** (20 Nov 2026, 10:24 pm)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-vpcs --region ap-south-1 --filters Name=isDefault,Values=true
>> aws ec2 describe-subnets --region ap-south-1 --filters Name=default-for-az,Values=true --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch}"                                                                         
{                                                                                                                                                            
    "Vpcs": [
        {
            "OwnerId": "908402822288",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-0d5639928609cbbdd",
                    "CidrBlock": "172.31.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": true,
            "BlockPublicAccessStates": {
                "InternetGatewayBlockMode": "off"
            },
            "VpcId": "vpc-011c6227ea559561e",
[                                                                                                                                                            
    {
        "az": "ap-south-1b",
        "cidr": "172.31.0.0/20",
        "publicIp": true
    },
    {
        "az": "ap-south-1c",
        "cidr": "172.31.16.0/20",
        "publicIp": true
    },
    {
        "az": "ap-south-1a",
        "cidr": "172.31.32.0/20",
        "publicIp": true
    }
]

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website>

---

**Tutor** (20 Nov 2026, 10:24 pm)

## Your output matches what I expected

- **Default VPC:** `vpc-011c6227ea559561e`, CIDR `172.31.0.0/16`.
- **Three subnets, one per AZ** (1a, 1b, 1c), each a `/20` (4,096 addresses).
- **All three have `publicIp: true`**, so anything launched there gets a public IP by default. There is no private layer at all. That is the weakness the customer's audit found.

Leave it alone. It costs $0, and you only used it for comparison.

## Why this matters for your CIDR choice

- `172.31.0.0/16` is **taken** by the default VPC, so don't reuse it. Overlapping ranges break peering, TGW and VPN later.
- Also off-limits per the brief: `192.168.1.0/24` (office) and `10.1.0.0/16` (another planned network).
- The default VPC is the only one that has the `isDefault` flag. Your new VPC will be a separate one, and your Project=aws-practice filter will return exactly one VPC, because the default one carries no such tag.

## Your turn: propose the ranges

Reply with:
1. **VPC CIDR.** Hint: stay in the `10.x.x.x` space, pick a second octet that is not `1`, and consider a `/16` or `/20`.
2. **Four subnet CIDRs.** Two public and two private, one of each per AZ (1a and 1b), non-overlapping and inside the VPC range.

Quick check while you decide: AWS reserves **5 addresses per subnet**. How many usable addresses does a `/24` leave? And what is the smallest subnet size AWS allows?

I'll sanity-check your answer before you open the console.

*SAP-C03 relevance: reserved-address math and CIDR planning show up often in multi-VPC and hybrid design questions.*

---

**You** (20 Nov 2026, 11:37 pm)

why /20 but we don't need that much address right

---

**Tutor** (20 Nov 2026, 11:38 pm)

## Two different "/20"s, and you're right to question both

**1. The default VPC's /20 subnets.**
- AWS just splits the default `/16` into one big `/20` per AZ (4,096 addresses, 4,091 usable).
- That's a generic default, not a sizing recommendation. It's oversized for most workloads.

**2. My "/16 or /20" hint for your VPC.**
- That was about leaving headroom, not about what Kesari needs today.

## What size should you pick?

- **IP addresses cost $0.** A bigger range doesn't increase your bill. The real costs of going too small are painful later.
- **A VPC's primary CIDR can't be changed.** You can only add secondary CIDRs, which is messy.
- **Oversizing subnets isn't free in a different way.** Big subnets eat your VPC's space, so you can fit fewer of them and may need to renumber later.

A common pattern:
- **VPC:** generous, such as a `/16` (65,536 addresses) or a `/20` (4,096). It's a free ceiling.
- **Subnets:** small and uniform, such as a `/24` (251 usable) each. For a handloom shop that's more than enough.

You could go even smaller, like `/27` (27 usable), but then you'd have little room if you add Lambda, containers or more servers later.

## Answers to my quick check

- A `/24` has 256 addresses, minus 5 reserved by AWS, so **251 usable**.
- The smallest subnet AWS allows is `/28` (16 addresses, 11 usable). The VPC range itself can be `/16` down to `/28`.

## Your turn

Pick your VPC CIDR and four subnet CIDRs, and say why you chose those sizes. Remember it must avoid `172.31.0.0/16`, `192.168.1.0/24` and `10.1.0.0/16`.

*SAP-C03 relevance: right-sizing CIDRs up front matters, since overlapping or exhausted ranges are a classic reason for painful redesigns in multi-account and hybrid questions.*

---

**You** (20 Nov 2026, 11:39 pm)

but then how it is possible two have this much amoount of cidr as ip's are limited right

---

**Tutor** (20 Nov 2026, 11:39 pm)

## Short answer: your VPC's IPs are private, not "real internet" IPs

There are two kinds of IPv4 addresses.

**1. Public IPv4: scarce.**
- There are only about 4.3 billion in total, and they must be globally unique.
- This is the shortage you've heard about.
- AWS charges for them (about $0.005/hr per address), which is why we avoid Elastic IPs we don't need.

**2. Private IPv4 (RFC 1918): effectively unlimited, because they're reusable.**
- Three ranges are reserved for private use and are **never routed on the public internet**:
  - `10.0.0.0/8`
  - `172.16.0.0/12`
  - `192.168.0.0/16`
- Every company, home router and VPC on Earth can use the same `10.x` addresses at once.
- Example: your home Wi-Fi is probably `192.168.x.x`, and so is your neighbour's. No conflict, because neither network can see the other.
- Your VPC's `10.x.x.x` range is just *your own private address book*. Picking a `/16` doesn't take anything from anyone else, and it costs $0.

## How private instances still reach the internet

- Only the **public subnet** instances get a public IP, and the **IGW** translates between the public and private address (a 1:1 mapping).
- Private subnets would normally use a NAT Gateway, which shares one public IP for many private ones. You are **not** building that at this level (about $41/month).

## When the "limit" does bite: overlap

- Two networks can reuse the same private range **only while they never connect**.
- The moment you link them (peering, VPN, Transit Gateway), the ranges must not overlap, because routers can't tell which `10.1.0.5` you mean.
- That's why the brief says to avoid `192.168.1.0/24` (office) and `10.1.0.0/16` (planned network). Your VPC CIDR is a **coordination problem**, not a scarcity problem.

## Your turn

Pick your VPC CIDR and four subnet CIDRs. Check each one against `172.31.0.0/16`, `192.168.1.0/24` and `10.1.0.0/16`, and I'll sanity-check them.

*SAP-C03 relevance: "overlapping CIDRs when connecting VPCs or on-prem" is a classic scenario, and the usual fixes are re-IP, PrivateLink, or NAT-based workarounds.*

---

**You** (20 Nov 2026, 11:41 pm)

give me steps I am new

---

**Tutor** (20 Nov 2026, 11:41 pm)

## Level 2 step-by-step (Console first)

Do these in order. Each step says what to click and what to check. Everything here is **$0** unless you launch the optional test instance.

### Before you start
- Region selector (top right): **Asia Pacific (Mumbai) ap-south-1**.
- Sign in as your **IAM user/role with MFA**, not root.
- On every resource, add tags: `Project = aws-practice` and a `Name`.

### Step 1: Decide your CIDRs (on paper first)
Here is one example layout to learn from. You can use it or pick your own, as long as it avoids `172.31.0.0/16`, `192.168.1.0/24` and `10.1.0.0/16`.

| Resource | CIDR | AZ |
|---|---|---|
| VPC | `10.20.0.0/16` | - |
| public-a | `10.20.1.0/24` | ap-south-1a |
| public-b | `10.20.2.0/24` | ap-south-1b |
| private-a | `10.20.11.0/24` | ap-south-1a |
| private-b | `10.20.12.0/24` | ap-south-1b |

Check: all four subnets sit inside `10.20.0.0/16` and don't overlap each other.

### Step 2: Create the VPC
- VPC console → **Create VPC** → choose **VPC only**.
- Name: `kesari-vpc`, IPv4 CIDR: `10.20.0.0/16`, no IPv6, tenancy Default.
- Add tag `Project=aws-practice`.

### Step 3: Create the 4 subnets
- VPC console → **Subnets** → **Create subnet**, select `kesari-vpc`.
- Add all four from the table, choosing the right AZ for each. Name them `public-a`, `public-b`, `private-a`, `private-b`, and tag each.
- For the **two public subnets only**: Actions → **Edit subnet settings** → enable **auto-assign public IPv4**.

### Step 4: Internet Gateway
- **Internet gateways** → Create (`kesari-igw`, tagged) → Actions → **Attach to VPC** → `kesari-vpc`.

### Step 5: Route tables
- **Route tables** → Create `public-rt` in `kesari-vpc`.
  - Routes → add `0.0.0.0/0` → target your IGW.
  - Subnet associations → select **public-a and public-b**.
- Create `private-rt` in `kesari-vpc`.
  - Leave routes as **local only**.
  - Associate **private-a and private-b**.

Note: the VPC's automatic "main" route table also exists. Explicitly associating your subnets (as above) keeps things clear.

### Step 6: Security groups
- **web-sg** (in `kesari-vpc`):
  - Inbound: HTTP 80 and HTTPS 443 from `0.0.0.0/0`.
  - Admin access: SSH 22 only from **your own IP /32** (find it by searching "what is my IP"), or skip SSH and use **Session Manager** later.
- **private-sg**:
  - Inbound: a test port such as 3306 (the future database), source = **web-sg** (pick the security group, not a CIDR).

### Step 7: Custom NACL for the private subnets
- **Network ACLs** → Create `private-nacl` in `kesari-vpc` → associate **private-a and private-b**.
- Inbound rules: allow all traffic (or specific ports) from `10.20.0.0/16` only.
- Outbound rules: allow TCP **1024-65535** to `10.20.0.0/16` (return traffic).
- Remember: NACLs are **stateless**, so you must allow return traffic yourself. Security groups are **stateful**.

### Step 8: Verify with the CLI
Run the six `describe-*` commands from your acceptance checklist. Replace `<vpc-id>` with your new VPC's ID. Tick each box as it passes.

### Step 9 (optional): Live test
- Launch one `t3.micro` (Amazon Linux 2023) in `public-a` with `web-sg`. Check its public IP and serve a test page.
- Launch a second in `private-a` with `private-sg` and **no public IP**.
- Cost: about $0.011/hr each plus about $0.005/hr for the public IP, which is pennies for a short session.
- **Terminate both when done.**

### Step 10: Delete everything the same day
Delete in this order: instances → NACL (after reassociating, or it goes with the VPC) → security groups → subnets → detach and delete IGW → route tables → VPC. Then run the clean-delete checks from the checklist.

## Your next move
Do Steps 1-3 now (VPC and subnets), then paste the output of:
```bash
aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=<vpc-id> --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch,name:Tags[?Key=='Name']|[0].Value}"
```
I'll check it before you continue.

*SAP-C03 relevance: this public/private, two-AZ layout is the base pattern behind most multi-tier design questions.*

---

**You** (20 Nov 2026, 11:48 pm)

can I change CIDR for exissing vpc

---

**Tutor** (20 Nov 2026, 11:48 pm)

## Short answer: you can't change the primary CIDR, but you can add to it

**What you can't do**
- The VPC's **primary** IPv4 CIDR is fixed once created. There is no "edit" for it.

**What you can do**
- **Add a secondary CIDR** to the VPC (VPC console → select VPC → Actions → **Edit CIDRs** → Add new IPv4 CIDR). It gives you more address space, and you can create new subnets in it.
- The secondary range must not overlap the primary or any peered network, and it must follow AWS's CIDR rules (e.g. a `10.x` primary has restrictions on some secondary ranges, such as `172.16.0.0/12`-type blocks, so check the docs).
- Existing subnets can't be resized either. You'd create new subnets in the new range.

**If you picked the wrong primary CIDR (the usual fix)**
1. Create a new VPC with the correct CIDR.
2. Rebuild or migrate resources into it.
3. Delete the old VPC.

## Why this is painless for you right now

- Level 2 is built and deleted the same day, and VPCs cost **$0**.
- If you get a CIDR wrong, just delete the VPC and recreate it. It takes minutes, with no cost.
- Terraform later makes this even easier, because you change one variable and re-apply (a changed `cidr_block` forces a replacement of the VPC).

## In real life

- This is why we plan CIDRs carefully up front. Replacing a VPC that holds a live database is a real migration project.

Docs: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html

*SAP-C03 relevance: "can't resize, so add a secondary CIDR or migrate" is a common answer when a scenario says the VPC is running out of IP space.*

Back to the build: have you picked your CIDRs yet? Paste your VPC CIDR and the four subnet CIDRs, and I'll check them before you click Create.

---

**You** (20 Nov 2026, 11:48 pm)

can I create two vpc with same cidr

---

**Tutor** (20 Nov 2026, 11:49 pm)

## Yes, AWS lets you, but it's a trap if they'll ever connect

**Why it's allowed**
- Each VPC is an isolated network. AWS doesn't check one VPC's CIDR against another's when you create it.
- Your default VPC and a new one can even share a range. That's fine while they stay separate.

**Why it's usually a bad idea**
- **VPC peering:** AWS refuses to peer two VPCs with overlapping CIDRs.
- **Transit Gateway:** overlapping attachments can't route to each other properly.
- **VPN / Direct Connect to the office:** routes become ambiguous, because a router can't tell which `10.20.0.5` you mean.
- Fixing it later means re-IPing or migrating, which is the painful path we talked about.

**When it's fine**
- Isolated environments that never connect, such as separate sandboxes or per-customer labs.
- Your Level 2 practice: if you build in the Console, delete, then rebuild in Terraform, reusing `10.20.0.0/16` is fine because the first VPC is gone.

**For this exercise**
- The checklist expects **exactly one** VPC tagged `Project=aws-practice`. Don't keep two at once. Delete the Console VPC before the Terraform rebuild.
- Cost: still **$0** either way.

**Workarounds if overlap already exists (exam favourites)**
- Re-IP one side.
- Use **AWS PrivateLink** to expose just specific services across overlapping networks.
- Use NAT-based translation in front of one network.

Docs: https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html

*SAP-C03 relevance: "overlapping CIDRs between VPCs or with on-prem" is a classic question, and PrivateLink is usually the answer when you can't re-IP.*

Ready to go? Paste your chosen VPC CIDR and four subnet CIDRs and I'll sanity-check them.

---

**You** (20 Nov 2026, 11:50 pm)

but how then vpc routing happens we add resource to vpc or what

---

**Tutor** (20 Nov 2026, 11:50 pm)

## Routing inside a VPC: it's built in, you don't add resources for it

**1. Local routing is automatic**
- Every VPC route table has a **local** route for the VPC's CIDR (e.g. `10.20.0.0/16 → local`).
- You can't delete it. Any subnet can reach any other subnet in the same VPC, as long as security groups and NACLs allow it.
- So `public-a` can talk to `private-b` with no extra setup.

**2. A route table is just a list of rules**
- Each rule says: "traffic for this destination CIDR goes to this target."
- AWS picks the **most specific match** (longest prefix).

Example public route table:

| Destination | Target |
|---|---|
| `10.20.0.0/16` | local |
| `0.0.0.0/0` | igw-xxxx |

Example private route table:

| Destination | Target |
|---|---|
| `10.20.0.0/16` | local |

**3. Subnets are linked to route tables (association)**
- Each subnet uses exactly one route table.
- If you don't associate one explicitly, the subnet uses the VPC's **main** route table.
- What makes a subnet "public" is **its route table has a route to an IGW**. The name doesn't matter.

**4. What you add depends on where traffic is going**

| Destination | What you add |
|---|---|
| Another subnet in the same VPC | Nothing (local route) |
| Internet | IGW + route `0.0.0.0/0 → igw` |
| Internet from private subnet | NAT Gateway (**not** building: about $41/month) |
| Another VPC | Peering or TGW + routes on both sides |
| Office network | VPN + routes |

**5. Resources (EC2 etc.) are not added to routing**
- An instance gets a private IP from its subnet, and uses that subnet's route table.
- Moving traffic around is controlled by: route table (where can it go?), then SG and NACL (is it allowed?).

**Why your private layer is private**
- The private route table has no IGW route, so there is no path to the internet. Even if someone opened a security group by mistake, packets have nowhere to go.

**Cost:** route tables and local routing are **$0**.

Docs: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

*SAP-C03 relevance: "longest prefix match, local route, one route table per subnet, and no transitive routing through peering" are all frequent exam points.*

Quick check: if `private-a` has only the local route, can it reach `public-b`? Answer, then paste your CIDRs when ready.

---

**You** (20 Nov 2026, 11:52 pm)

but how vpc is connected then if I want to connect it with outside world

---

**Tutor** (20 Nov 2026, 11:52 pm)

## Connecting a VPC to the outside world: you attach a gateway, then add a route

A VPC is isolated by default. Nothing gets in or out until you attach a "door" and point a route at it.

**Your quick check first:** yes, `private-a` can reach `public-b`. The local route covers the whole VPC CIDR, and SGs and NACLs still decide whether the traffic is allowed.

## The doors

| Where to | Door (attach to VPC) | Route you add | Cost (ap-south-1) |
|---|---|---|---|
| Internet (both ways) | **Internet Gateway (IGW)** | `0.0.0.0/0 → igw-xxx` | **$0** |
| Internet (outbound only, from private) | NAT Gateway | `0.0.0.0/0 → nat-xxx` | about $0.056/hr (~$41/month). **Not at this level** |
| AWS services privately | VPC endpoints | route or ENI | Gateway endpoints for S3/DynamoDB are free; interface endpoints are billed. **Not at this level** |
| Another VPC | Peering or Transit Gateway | CIDR of other VPC → pcx/tgw | Peering has no hourly fee; TGW is billed. Later levels |
| Office / on-prem | Site-to-Site VPN (or Direct Connect) | office CIDR → vgw/tgw | VPN is billed. Later levels |

For Level 2, you only need the **IGW**.

## How a request from a customer reaches your web server

1. Customer's browser sends traffic to your instance's **public IP**.
2. The **IGW** translates the public IP to the instance's private IP (1:1 mapping).
3. The **NACL** on the subnet checks it, then the **security group** on the instance checks it (80/443 allowed).
4. The reply goes out via the subnet's route table (`0.0.0.0/0 → IGW`) and the IGW translates back.

## Three things must all be true for a public subnet

- An IGW is **attached** to the VPC.
- The subnet's route table has `0.0.0.0/0 → IGW`.
- The instance has a **public IPv4** (auto-assign on, or an Elastic IP).

Miss any one and the instance is not reachable from the internet. That is why your private subnets stay private: there is no IGW route, and no public IPs.

## Where this fits in your build

- Steps 4 and 5 of the guide are exactly this: create and attach the IGW, then add the route to the public route table only.
- Nothing else is needed for connectivity at this level.

Docs: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html

*SAP-C03 relevance: choosing the right gateway (IGW vs NAT vs endpoint vs peering vs TGW vs VPN) for a given connectivity requirement is core exam material.*

Next: paste your VPC CIDR and four subnet CIDRs, and I'll check them before you click Create.

---

**You** (21 Nov 2026, 12:02 am)

how to make subnet private

---

**Tutor** (21 Nov 2026, 12:03 am)

## A subnet is "private" because of its route table, not a setting

There's no "make private" button. A subnet is private when **nothing gives it a path to or from the internet**.

## Checklist for a private subnet

1. **Route table has no route to an IGW.**
   - Only the `local` route (`10.20.0.0/16 → local`).
   - No `0.0.0.0/0` route at all at this level (a NAT route would give outbound-only access, but we're not building that).
2. **Auto-assign public IPv4 is OFF** on the subnet.
   - Subnets → select it → Actions → Edit subnet settings → leave "Enable auto-assign public IPv4 address" unticked.
3. **Instances launched there get no public IP.**
4. **Security group and NACL are locked down** (private-sg allows only web-sg; private NACL allows only the VPC CIDR).

## How to do it in the Console

1. Create the subnet (e.g. `private-a`, `10.20.11.0/24`, ap-south-1a), tagged `Project=aws-practice`.
2. Create a route table `private-rt` and leave routes as local only.
3. **Route tables → private-rt → Subnet associations → Edit** → tick `private-a` and `private-b`.

## Watch out for the main route table

- If you don't associate a subnet with a route table explicitly, it uses the VPC's **main** route table.
- Never add an IGW route to the main route table. Otherwise every unassociated subnet becomes public by accident.
- Explicit association (as above) avoids this.

## Verify with the CLI

```bash
aws ec2 describe-route-tables --region ap-south-1 \
  --filters Name=association.subnet-id,Values=<private-subnet-id> \
  --query "RouteTables[].Routes"
```

Expected: only the `local` route, with no `igw-` target.

```bash
aws ec2 describe-subnets --region ap-south-1 --subnet-ids <private-subnet-id> \
  --query "Subnets[].MapPublicIpOnLaunch"
```

Expected: `false`.

**Cost:** $0.

Docs: https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html

*SAP-C03 relevance: "public vs private subnet is defined by the route table (IGW route), not by a flag" is a frequent exam trap.*

Next: paste your VPC CIDR and four subnet CIDRs and I'll check them before you click Create.

---

**You** (21 Nov 2026, 12:04 am)

pub-a

subnet-021c32d1d55cae2b8
ARN
Available
vpc-011c6227ea559561e
Off
–
172.31.1.0/24
–
–
251
aps1-az1 (ap-south-1a)
ap-south-1
rtb-0e326f0b2d0a3ec4f
Yes (public)
–
No
No
No
-
No
908402822288
pvt-b
subnet-0b9d261722eb31057
ARN
Available
vpc-011c6227ea559561e
Off
–
172.31.12.0/24
–
–
251
aps1-az3 (ap-south-1b)
ap-south-1
rtb-0e326f0b2d0a3ec4f
Yes (public)
–
No
No
No
-
No
908402822288
pvt-a
subnet-0e34b2e776c0a1e4e
ARN
Available
vpc-011c6227ea559561e
Off
–
172.31.11.0/24
–
–
251
aps1-az1 (ap-south-1a)
ap-south-1
rtb-0e326f0b2d0a3ec4f
Yes (public)
–
No
No
No
-
No
908402822288
pub-b
subnet-04d8903eba73380b2
ARN
Available
vpc-011c6227ea559561e
Off
–
172.31.2.0/24
–
–
251
aps1-az3 (ap-south-1b)
ap-south-1
rtb-0e326f0b2d0a3ec4f
Yes (public)
–
No
No
No
-
No
908402822288

---

**Tutor** (21 Nov 2026, 12:04 am)

## Stop and check: these four subnets are in the default VPC

Look at the VPC ID: `vpc-011c6227ea559561e`. That's the **default VPC** from your earlier output, with CIDR `172.31.0.0/16`. Your subnets are `172.31.x.x`, so they sit inside it.

⚠️ Stop: this is the customer's original mistake. The default VPC's main route table (`rtb-0e326f0b2d0a3ec4f`) already routes to the internet, so your `pvt-a` and `pvt-b` show **"Yes (public)"**. They are public, not private.

## What to fix

1. **Delete these four subnets** (VPC → Subnets → select → Actions → Delete). They're empty and free, so nothing is lost.
2. **Create a new VPC** (VPC → Create VPC → *VPC only*):
   - Name `kesari-vpc`, CIDR `10.20.0.0/16` (or your own choice that avoids `172.31.0.0/16`, `192.168.1.0/24`, `10.1.0.0/16`).
   - Tag `Project=aws-practice`.
3. **Recreate the four subnets inside `kesari-vpc`.** When creating a subnet, the first dropdown is the VPC, so select `kesari-vpc`, not the default one.

| Name | CIDR | AZ |
|---|---|---|
| pub-a | `10.20.1.0/24` | ap-south-1a |
| pub-b | `10.20.2.0/24` | ap-south-1b |
| pvt-a | `10.20.11.0/24` | ap-south-1a |
| pvt-b | `10.20.12.0/24` | ap-south-1b |

4. Tag every subnet with `Project=aws-practice`.

## Other things I noticed

- **Auto-assign public IPv4 is "No"** on all four. Public subnets (`pub-a`, `pub-b`) need it **on**, so enable it after creating them in the new VPC. Keep it off on the private ones.
- **AZ names vs IDs:** `ap-south-1a` is `aps1-az1` and `ap-south-1b` is `aps1-az3` in your account. That's fine. Names map to different IDs per account.
- The default VPC has no Project tag, so leave it alone. Don't delete it.

## Check when done

```bash
aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=<new-vpc-id> --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch,name:Tags[?Key=='Name']|[0].Value}"
```

Paste the output and I'll check it. **Cost:** $0.

*SAP-C03 relevance: "default VPC subnets are all public" is a known gotcha, and exam answers usually say to build a custom VPC.*

---

**You** (21 Nov 2026, 12:04 am)

but why this is public by default what do you mean

---

**Tutor** (21 Nov 2026, 12:05 am)

## Why "public by default": it's the default VPC's wiring, not the subnet

Your subnets didn't choose to be public. They inherited it from the VPC they were created in.

**What AWS sets up for the default VPC (automatically, at account creation)**
- An **Internet Gateway** already attached.
- A **main route table** that already contains `0.0.0.0/0 → igw-xxx`.
- Subnets (one per AZ) with **auto-assign public IPv4 = on**.

**What happens when you create a subnet there**
- You don't associate a route table, so the subnet falls back to the **main route table**.
- The main route table has the IGW route, so the subnet is public.
- That's why the console showed `rtb-0e326f0b2d0a3ec4f` and **"Yes (public)"** for even `pvt-a` and `pvt-b`. The name "pvt" is just a label. The route table decides.

## Compare with a VPC you create yourself

| | Default VPC | Your custom VPC |
|---|---|---|
| IGW | Created and attached for you | None until you create it |
| Main route table | Has `0.0.0.0/0 → IGW` | Only `local` |
| New subnets | Public automatically | Private until you add an IGW route |
| Auto-assign public IP | On | Off |

So in a custom VPC, everything starts private, and you deliberately make `pub-a` and `pub-b` public by:
1. Attaching an IGW.
2. Creating `public-rt` with `0.0.0.0/0 → IGW`.
3. Associating it with the two public subnets only.

## Why this matters for the customer

- The freelancer used the default VPC, so the database sat in a subnet with a route to the internet and (probably) a public IP.
- With a permissive security group (port open to `0.0.0.0/0`), it was reachable from anywhere. That is exactly what the audit found.
- In your design, the private subnets have **no route to the IGW**, so even a security group mistake can't expose them. That's defence in depth.

## Your next step

1. Delete the four subnets in the default VPC.
2. Create `kesari-vpc` (`10.20.0.0/16`) and recreate the subnets inside it.
3. Paste the `describe-subnets` output for the new VPC.

**Cost:** $0.

Docs: https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html

*SAP-C03 relevance: knowing the default VPC is public-by-design (IGW, main route table, auto-assign IP) and that custom VPCs start closed is a common exam distinction.*

---

**You** (21 Nov 2026, 12:06 am)

and we can't remove that default vps IGW

---

**Tutor** (21 Nov 2026, 12:06 am)

## You can, but you shouldn't, and you don't need to

**Technically possible**
- Detach the IGW (VPC → Internet gateways → Actions → **Detach from VPC**), then delete it. The default VPC isn't locked.
- You'd have to remove the `0.0.0.0/0 → igw` route from the main route table first, or the detach fails with a "mapped public addresses" or dependency error.
- You can also delete the whole default VPC (Actions → Delete VPC). AWS can recreate it later (Actions → **Create default VPC**).

**Why I'd leave it alone for now**
- The customer's old setup lives in that style of VPC, and it costs **$0** to keep. An IGW, route table and subnets are all free.
- Removing it teaches you nothing for Level 2, and you might break something you want later (for example, quick tests).
- Your new `kesari-vpc` is completely separate. The default VPC's IGW has no effect on it.

**Safer alternative if the exposure bothers you**
- Just don't launch anything in the default VPC. An empty default VPC can't expose anything.
- Optional extra guard: VPC → Settings → **Block public access** can block internet gateway traffic account-wide. Your earlier output showed `InternetGatewayBlockMode: off`. Don't turn it on yet, though, because it would also block your own public test instance later.

**A real-world note**
- Many companies delete default VPCs in every region as a baseline hardening step, but that's usually done with account-wide policy tooling in later levels. It's not needed today.

**Cost:** $0 either way.

Docs: https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html

*SAP-C03 relevance: "delete default VPCs in all regions" is a common multi-account governance recommendation.*

Next: delete the four subnets in the default VPC, create `kesari-vpc`, and paste the `describe-subnets` output for the new VPC.

---

**You** (21 Nov 2026, 12:14 am)

Done I created all private

---

**Tutor** (21 Nov 2026, 12:14 am)

## Good start, now let's verify it

"All private" is exactly right for a fresh custom VPC: no IGW, only the local route. That's the safe starting state. The two public subnets become public in the next steps.

Paste the output of this (replace `<new-vpc-id>`):

```bash
aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=<new-vpc-id> --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
```

Check these before pasting:
- The VPC ID is **not** `vpc-011c6227ea559561e` (that's the default VPC).
- Four subnets: `pub-a`, `pub-b`, `pvt-a`, `pvt-b`, with one of each in 1a and 1b.
- All CIDRs sit inside your VPC CIDR and don't overlap.
- `project` shows `aws-practice` on each.
- Also confirm the four old subnets in the default VPC are deleted.

## Next steps (all $0)

1. **Make the two public subnets public.** Three pieces:
   - Create an IGW (`kesari-igw`, tagged) and attach it to your VPC.
   - Create `public-rt` with `0.0.0.0/0 → kesari-igw`, and associate it with **pub-a and pub-b only**.
   - Enable **auto-assign public IPv4** on pub-a and pub-b only.
2. **Make the private subnets explicitly private.** Create `private-rt` (local route only) and associate it with pvt-a and pvt-b.
3. Then security groups and the NACL.

Do step 1 first, then run:

```bash
aws ec2 describe-route-tables --region ap-south-1 --filters Name=vpc-id,Values=<new-vpc-id>
```

Paste it and I'll check that the routes and associations are right.

*SAP-C03 relevance: starting closed and opening only what's needed (least privilege at the network layer) is the pattern behind most secure-architecture answers.*

---

**You** (21 Nov 2026, 12:15 am)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=vpc-011a934f2885b9c9b --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"  
>> 
[                                                                                                                                                            
    {
        "az": "ap-south-1b",
        "cidr": "172.1.3.0/24",
        "publicIp": false,
        "name": "pub-bq",
        "project": null
    },
    {
        "az": "ap-south-1b",
        "cidr": "172.1.4.0/24",
        "publicIp": false,
        "name": "pvt-b",
        "project": null
    },
    {
        "az": "ap-south-1a",
        "cidr": "172.1.1.0/24",
        "publicIp": false,
        "name": "pub-a",
        "project": null
    },
    {
        "az": "ap-south-1a",
        "cidr": "172.1.2.0/24",
        "publicIp": false,
        "name": "pvt-a",
        "project": null
    }
]

---

**Tutor** (21 Nov 2026, 12:15 am)

## Good progress: the VPC is correct, but fix 3 things before moving on

The VPC ID `vpc-011a934f2885b9c9b` is new (not the default one), and you have four subnets, one public and one private in each of 1a and 1b. 

## Fixes needed

**1. Missing tags (`project: null` on all four)**
- Every resource needs `Project=aws-practice` so leftovers can be found, and the checklist filters on it.
- Fix: VPC → Subnets → select a subnet → **Tags** tab → **Manage tags** → add `Project = aws-practice`. Repeat for all four.
- Check the **VPC itself** too (VPC → Your VPCs → `vpc-011a934f2885b9c9b` → Tags). The checklist's `describe-vpcs` filter on `tag:Project` needs it, or it will return nothing.

**2. Typo in a name: `pub-bq`**
- Rename to `pub-b` (Tags tab → edit the `Name` value).

**3. CIDR check: `172.1.x.x` is probably not what you intended**
- `172.1.0.0/24`-style ranges are **public internet addresses**, not private (RFC 1918 private space is `172.16.0.0/12`, i.e. `172.16.x.x` to `172.31.x.x`).
- It works technically, but it's bad practice: if your VPC ever needs to reach the real `172.1.x.x` hosts on the internet, they would be unreachable, because the local route would capture that traffic.
- What is your **VPC CIDR**? Run:

```bash
aws ec2 describe-vpcs --region ap-south-1 --vpc-ids vpc-011a934f2885b9c9b --query "Vpcs[].CidrBlockAssociationSet[].CidrBlock"
```

- Since VPCs cost $0 and the primary CIDR can't be edited, the clean fix is to **delete the four subnets and this VPC**, then recreate with `10.20.0.0/16` and the table from earlier (`10.20.1.0/24`, `10.20.2.0/24`, `10.20.11.0/24`, `10.20.12.0/24`). It takes about 5 minutes.
- If you want to keep it for practice, a private-range choice like `172.16.0.0/16` is the minimum fix, but remember it must not overlap `172.31.0.0/16`, `192.168.1.0/24` or `10.1.0.0/16`.

## What's right

- Two AZs, with one public and one private subnet each.
- Public IP auto-assign is `false` on all four, the correct start. You'll turn it on for `pub-a` and `pub-b` only, after the IGW and route table exist.

## Next

1. Run the VPC CIDR command above and paste the result.
2. Decide: recreate with `10.20.0.0/16` (recommended) or keep and re-range.
3. Then continue with the IGW and route tables.

**Cost:** $0.

*SAP-C03 relevance: using non-RFC1918 ranges inside a VPC is a known anti-pattern, since it can break routing to real public destinations and complicates hybrid connectivity.*

---

**You** (21 Nov 2026, 12:17 am)

give me command for updating tags

---

**Tutor** (21 Nov 2026, 12:17 am)

## Tagging with the CLI: `aws ec2 create-tags`

`create-tags` adds a tag or overwrites the value if the key already exists. It works on many resource IDs at once, and it's **$0**.

**1. Tag the VPC and all four subnets (adds Project)**

First get the subnet IDs:

```bash
aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=vpc-011a934f2885b9c9b --query "Subnets[].{id:SubnetId,name:Tags[?Key=='Name']|[0].Value}"
```

Then tag (replace the placeholders with your IDs):

```bash
aws ec2 create-tags --region ap-south-1 --resources vpc-011a934f2885b9c9b <subnet-id-1> <subnet-id-2> <subnet-id-3> <subnet-id-4> --tags Key=Project,Value=aws-practice
```

**2. Fix the `pub-bq` typo (overwrites the Name value)**

```bash
aws ec2 create-tags --region ap-south-1 --resources <pub-bq-subnet-id> --tags Key=Name,Value=pub-b
```

**3. Name the VPC too (if it has no Name)**

```bash
aws ec2 create-tags --region ap-south-1 --resources vpc-011a934f2885b9c9b --tags Key=Name,Value=kesari-vpc
```

**4. Verify**

```bash
aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=vpc-011a934f2885b9c9b --query "Subnets[].{cidr:CidrBlock,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
aws ec2 describe-vpcs --region ap-south-1 --filters Name=tag:Project,Values=aws-practice --query "Vpcs[].VpcId"
```

Expected: `project` shows `aws-practice` on all four, and the VPC ID appears in the second command.

## Notes

- **PowerShell:** the commands above work as is. If a tag value ever contains spaces, wrap it like `--tags "Key=Name,Value=my name"`.
- To remove a tag: `aws ec2 delete-tags --resources <id> --tags Key=Project`.
- Later resources (IGW, route tables, SGs, NACL) can be tagged at creation in the console ("Add tag" on the create screen), which saves this step.

## Still open from last time

You haven't shown your **VPC CIDR** yet. Run this and paste it:

```bash
aws ec2 describe-vpcs --region ap-south-1 --vpc-ids vpc-011a934f2885b9c9b --query "Vpcs[].CidrBlockAssociationSet[].CidrBlock"
```

If it's in the `172.1.x.x` range, I still recommend recreating with `10.20.0.0/16`, since tagging a VPC you'll replace is wasted effort.

Docs: https://docs.aws.amazon.com/cli/latest/reference/ec2/create-tags.html

*SAP-C03 relevance: consistent tagging underpins cost allocation and tag-based governance (tag policies, SCPs, resource groups) in multi-account questions.*

---

**You** (21 Nov 2026, 12:20 am)

ue=pub-b
>> 
PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=vpc-011a934f2885b9c9b --query "Subnets[].{cidr:CidrBlock,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
>> aws ec2 describe-vpcs --region ap-south-1 --filters Name=tag:Project,Values=aws-practice --query "Vpcs[].VpcId"
>> 
[                                                                                                                                                            
    {
        "cidr": "172.1.3.0/24",
        "name": "pub-b",
        "project": "aws-practice"
    },
    {
        "cidr": "172.1.4.0/24",
        "name": "pvt-b",
        "project": "aws-practice"
    },
    {
        "cidr": "172.1.1.0/24",
        "name": "pub-a",
        "project": "aws-practice"
    },
    {
        "cidr": "172.1.2.0/24",
        "name": "pvt-a",
        "project": "aws-practice"
    }
]

[                                                                                                                                                            
    "vpc-011a934f2885b9c9b"
]

---

**Tutor** (21 Nov 2026, 12:20 am)

## Tags are fixed

- All four subnets now show `Project=aws-practice` and the `pub-bq` typo is now `pub-b`.
- The VPC `vpc-011a934f2885b9c9b` is returned by the Project filter, so the checklist's `describe-vpcs` check will find it.

Note: PowerShell ran the two commands as one paste, which is why both outputs appeared together. That's fine.

## Still open: your VPC CIDR

I still haven't seen it. Run:

```bash
aws ec2 describe-vpcs --region ap-south-1 --vpc-ids vpc-011a934f2885b9c9b --query "Vpcs[].CidrBlockAssociationSet[].CidrBlock"
```

Your subnets are `172.1.x.x`, which is **public internet address space**, not private (private is `172.16.0.0/12`). It works technically, but it's a bad habit and an interviewer would flag it.

## Decision for you

- **Option A (recommended):** delete the 4 subnets and the VPC, then recreate with `10.20.0.0/16` and subnets `10.20.1.0/24`, `10.20.2.0/24`, `10.20.11.0/24`, `10.20.12.0/24`. About 5 minutes, $0. You can tag at creation time this time.
- **Option B:** keep it for the learning flow, and accept the CIDR is wrong. Don't carry it into the Terraform rebuild.

Option A is cleaner because the primary CIDR can't be edited, and the checklist expects an agreed CIDR that avoids overlap with the office and planned networks.

## Next steps (after you pick)

1. Create the IGW `kesari-igw` (tag `Project=aws-practice`) and attach it to the VPC.
2. Create `public-rt` with `0.0.0.0/0 → kesari-igw`, associated with **pub-a and pub-b only**.
3. Create `private-rt` (local only), associated with **pvt-a and pvt-b**.
4. Turn on auto-assign public IPv4 for pub-a and pub-b only.

Then paste:

```bash
aws ec2 describe-route-tables --region ap-south-1 --filters Name=vpc-id,Values=<vpc-id>
```

**Cost:** $0.

*SAP-C03 relevance: using RFC 1918 ranges and planning CIDRs to avoid overlap is a recurring theme in hybrid and multi-VPC scenarios.*

---

**You** (21 Nov 2026, 12:22 am)

Option A (recommended): delete the 4 subnets and the VPC, then recreate with 10.20.0.0/16 and subnets 10.20.1.0/24, 10.20.2.0/24, 10.20.11.0/24, 10.20.12.0/24. About 5 minutes, $0. You can tag at creation time this time.
give me commands now I'll do it from commands as I know what to do with tags and everything so then I'll start igw setup after that new cidr range

---

**Tutor** (21 Nov 2026, 12:22 am)

## Option A via CLI: delete, recreate, tag at creation

Everything here is **$0**. Run in PowerShell. Variables use `$name = ...` syntax.

Note: the learner's setup has levels 1-5 built by hand in the Console first. Using the CLI for creation is fine for this rebuild since you've already done the Console flow, and it's good practice for the verification commands.

### 1. Delete the old subnets and VPC

```powershell
$OLD = "vpc-011a934f2885b9c9b"
$R = "ap-south-1"

# delete the 4 subnets
aws ec2 describe-subnets --region $R --filters Name=vpc-id,Values=$OLD --query "Subnets[].SubnetId" --output text | ForEach-Object { $_ -split "\s+" } | ForEach-Object { aws ec2 delete-subnet --region $R --subnet-id $_ }

# delete the VPC
aws ec2 delete-vpc --region $R --vpc-id $OLD
```

If the VPC delete fails with a dependency error, something else is attached (an IGW, custom route table, SG, or NACL). Paste the error and I'll help.

### 2. Create the new VPC (tagged at creation)

```powershell
$VPC = aws ec2 create-vpc --region $R --cidr-block 10.20.0.0/16 `
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=kesari-vpc},{Key=Project,Value=aws-practice}]" `
  --query "Vpc.VpcId" --output text
$VPC
```

### 3. Create the 4 subnets (tagged at creation)

```powershell
function New-Sub($name, $cidr, $az) {
  aws ec2 create-subnet --region $R --vpc-id $VPC --cidr-block $cidr --availability-zone $az `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$name},{Key=Project,Value=aws-practice}]" `
    --query "Subnet.SubnetId" --output text
}

$PUBA = New-Sub "pub-a" "10.20.1.0/24"  "ap-south-1a"
$PUBB = New-Sub "pub-b" "10.20.2.0/24"  "ap-south-1b"
$PVTA = New-Sub "pvt-a" "10.20.11.0/24" "ap-south-1a"
$PVTB = New-Sub "pvt-b" "10.20.12.0/24" "ap-south-1b"
```

### 4. Verify

```powershell
aws ec2 describe-vpcs --region $R --filters Name=tag:Project,Values=aws-practice --query "Vpcs[].{id:VpcId,cidr:CidrBlock,name:Tags[?Key=='Name']|[0].Value}"

aws ec2 describe-subnets --region $R --filters Name=vpc-id,Values=$VPC --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
```

Expected:
- Exactly **one** VPC tagged `Project=aws-practice`, with CIDR `10.20.0.0/16`.
- Four subnets in `10.20.x.x`, one public and one private per AZ, all with `project = aws-practice`, and `publicIp = false` for now.

### Notes

- Keep the PowerShell window open so `$VPC`, `$PUBA` and the others stay available for the IGW step. If you close it, re-fetch the IDs with `describe-subnets`.
- If `create-vpc` complains about the tag syntax in PowerShell, wrap the whole `--tag-specifications` value in single quotes instead.
- Don't delete the default VPC (`vpc-011c6227ea559561e`).

Docs: https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html

Paste the verify output and then we start the IGW and route tables.

*SAP-C03 relevance: tagging at creation (via `--tag-specifications`) is what tag-based IAM conditions and tag policies can enforce.*

---

**You** (21 Nov 2026, 12:24 am)

>> aws ec2 describe-subnets --region $R --filters Name=vpc-id,Values=$VPC --query "Subnets[].{az:AvailabilityZone,cidr:CidrBlock,publicIp:MapPublicIpOnLaunch,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
>>  
[                                                                                                                                                            
    {
        "id": "vpc-05d1495f13b08e8fc",
        "cidr": "10.20.0.0/16",
        "name": "kesari-vpc"
    }
]

[                                                                                                                                                            
    {
        "az": "ap-south-1b",
        "cidr": "10.20.2.0/24",
        "publicIp": false,
        "name": "pub-b",
        "project": "aws-practice"
    },
    {
        "az": "ap-south-1a",
        "cidr": "10.20.1.0/24",
        "publicIp": false,
        "name": "pub-a",
        "project": "aws-practice"
    },
    {
        "az": "ap-south-1a",
        "cidr": "10.20.11.0/24",
        "publicIp": false,
        "name": "pvt-a",
        "project": "aws-practice"
    },
    {
        "az": "ap-south-1b",
        "cidr": "10.20.12.0/24",
        "publicIp": false,
        "name": "pvt-b",
        "project": "aws-practice"
    }
]

---

**Tutor** (21 Nov 2026, 12:24 am)

## Foundation checks out

- Exactly one VPC tagged `Project=aws-practice`: `vpc-05d1495f13b08e8fc`, CIDR `10.20.0.0/16`, no overlap with `172.31.0.0/16`, `192.168.1.0/24` or `10.1.0.0/16`.
- Four subnets, one public and one private in each of 1a and 1b, all tagged, all in `10.20.x.x`.
- `publicIp = false` everywhere is correct for now. You'll turn it on for pub-a and pub-b after the IGW and route table exist.
- The old `172.1.x.x` VPC no longer shows up under the Project tag, so the delete worked.

You can tick the first two checklist boxes (VPC and subnets). The "only public subnets show MapPublicIpOnLaunch=true" part comes after step 4 below.

## Next: IGW and route tables (all $0)

Your `$VPC`, `$PUBA`, `$PUBB`, `$PVTA`, `$PVTB` and `$R` variables should still be set in this window. Check with `$VPC`.

**1. Create and attach the IGW**

```powershell
$IGW = aws ec2 create-internet-gateway --region $R `
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=kesari-igw},{Key=Project,Value=aws-practice}]" `
  --query "InternetGateway.InternetGatewayId" --output text
aws ec2 attach-internet-gateway --region $R --internet-gateway-id $IGW --vpc-id $VPC
```

**2. Public route table: route to the IGW, associate with pub-a and pub-b only**

```powershell
$PUBRT = aws ec2 create-route-table --region $R --vpc-id $VPC `
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-rt},{Key=Project,Value=aws-practice}]" `
  --query "RouteTable.RouteTableId" --output text
aws ec2 create-route --region $R --route-table-id $PUBRT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW
aws ec2 associate-route-table --region $R --route-table-id $PUBRT --subnet-id $PUBA
aws ec2 associate-route-table --region $R --route-table-id $PUBRT --subnet-id $PUBB
```

**3. Private route table: local only, associate with pvt-a and pvt-b**

Your turn on this one. It's the same pattern as step 2, with two differences:
- the tag Name is `private-rt`
- there is **no** `create-route` line, so only the `local` route exists

**4. Auto-assign public IPv4 on the public subnets only**

```powershell
aws ec2 modify-subnet-attribute --region $R --subnet-id $PUBA --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --region $R --subnet-id $PUBB --map-public-ip-on-launch
```

## Verify

```powershell
aws ec2 describe-route-tables --region $R --filters Name=vpc-id,Values=$VPC --query "RouteTables[].{name:Tags[?Key=='Name']|[0].Value,routes:Routes[].[DestinationCidrBlock,GatewayId],subnets:Associations[].SubnetId}"
aws ec2 describe-internet-gateways --region $R --filters Name=attachment.vpc-id,Values=$VPC --query "InternetGateways[].Attachments[].State"
```

Expected:
- `public-rt`: `10.20.0.0/16 → local`, `0.0.0.0/0 → igw-...`, with pub-a and pub-b associated.
- `private-rt`: only `10.20.0.0/16 → local`, with pvt-a and pvt-b associated.
- The VPC's automatic main route table also appears, with local only and no subnets. That's fine, and you should **not** add an IGW route to it.
- IGW state shows `available`.

Paste the output and I'll check it.

*SAP-C03 relevance: IGW attached plus a `0.0.0.0/0` route in an explicitly associated route table is what makes a subnet public, and it's a staple of multi-tier VPC questions.*

---

**You** (21 Nov 2026, 12:25 am)

I created igw and attached to vpc is it not correct

---

**Tutor** (21 Nov 2026, 12:25 am)

## Yes, that's correct, but it's only step 1 of 3

Creating the IGW and attaching it to `vpc-05d1495f13b08e8fc` is exactly right. On its own it doesn't make any subnet public yet, because nothing routes to it.

## Quick check that it attached properly

```powershell
aws ec2 describe-internet-gateways --region $R --filters Name=attachment.vpc-id,Values=$VPC --query "InternetGateways[].{id:InternetGatewayId,state:Attachments[0].State,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
```

Expected: exactly one IGW, state `available`, with Name and Project tags. If `$VPC` or `$R` are empty (new window), use the literal values: `vpc-05d1495f13b08e8fc` and `ap-south-1`.

If you created it in the Console, make sure you added `Project=aws-practice` on the create screen. If not, fix it with `aws ec2 create-tags`.

## Still to do for the public layer

1. **Route table:** create `public-rt` with `0.0.0.0/0 → your IGW`, and associate it with **pub-a and pub-b only**.
2. **Auto-assign public IPv4** on pub-a and pub-b only.
3. **Private route table:** `private-rt` with local only, associated with pvt-a and pvt-b.

The commands for these are in my previous message (steps 2 to 4). If your IGW came from the Console, set `$IGW` first:

```powershell
$IGW = "igw-xxxxxxxx"   # your IGW id
```

Then run step 2 from before. Once done, paste the `describe-route-tables` output and I'll check it.

**Cost:** $0. An IGW has no hourly charge.

*SAP-C03 relevance: IGW attached plus a route is the minimum for a public subnet, and exam questions often hide the missing route as the cause of "can't reach the internet".*

---

**You** (21 Nov 2026, 12:26 am)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-internet-gateways --region $R --filters Name=attachment.vpc-id,Values=$VPC --query "InternetGateways[].{id:InternetGatewayId,state:Attachments[0].State,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
>> 
[                                                                                                                                                            
    {
        "id": "igw-0dae1d4a59f8bad33",
        "state": "available",
        "name": "kesari-igw",
        "project": "aws-practice"
    }
]

---

**Tutor** (21 Nov 2026, 12:26 am)

## IGW is correct

- One IGW, `igw-0dae1d4a59f8bad33`, state `available`, attached to your VPC (the filter on `attachment.vpc-id` returned it, so it's attached to `$VPC`).
- Tags are right: `Name=kesari-igw`, `Project=aws-practice`.
- You can tick the IGW checklist box.
- **Cost:** $0.

## Next: make it do something (route table)

Nothing is public yet. The IGW is a door with no road leading to it. Set the variable first:

```powershell
$IGW = "igw-0dae1d4a59f8bad33"
```

Then run the public route table block from before:

```powershell
$PUBRT = aws ec2 create-route-table --region $R --vpc-id $VPC `
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-rt},{Key=Project,Value=aws-practice}]" `
  --query "RouteTable.RouteTableId" --output text
aws ec2 create-route --region $R --route-table-id $PUBRT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW
aws ec2 associate-route-table --region $R --route-table-id $PUBRT --subnet-id $PUBA
aws ec2 associate-route-table --region $R --route-table-id $PUBRT --subnet-id $PUBB
```

Then try the private route table yourself (same pattern, tag `private-rt`, **no** `create-route` line, associate with `$PVTA` and `$PVTB`).

Finally, turn on auto-assign public IPv4 for pub-a and pub-b only:

```powershell
aws ec2 modify-subnet-attribute --region $R --subnet-id $PUBA --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --region $R --subnet-id $PUBB --map-public-ip-on-launch
```

## Verify

```powershell
aws ec2 describe-route-tables --region $R --filters Name=vpc-id,Values=$VPC --query "RouteTables[].{name:Tags[?Key=='Name']|[0].Value,routes:Routes[].[DestinationCidrBlock,GatewayId],subnets:Associations[].SubnetId}"
```

Paste the output and I'll check the routes and associations.

*SAP-C03 relevance: "IGW attached but no route" is a classic troubleshooting scenario.*

---

**You** (21 Nov 2026, 12:27 am)

can you first tell me what in console we need to do and why

---

**Tutor** (21 Nov 2026, 12:27 am)

## Console steps for the public/private split, and why

All of this is **$0**. Your IGW is already attached, so we start from the route tables.

## Step 1: Public route table

**Console:** VPC → Route tables → **Create route table**
- Name `public-rt`, VPC `kesari-vpc`, tag `Project=aws-practice` → Create.
- Open it → **Routes** tab → **Edit routes** → **Add route**: destination `0.0.0.0/0`, target **Internet Gateway** → `kesari-igw` → Save.
- **Subnet associations** tab → **Edit subnet associations** → tick **pub-a** and **pub-b** only → Save.

**Why:**
- The IGW is a door, and the route is the road to it. `0.0.0.0/0` means "anything not in the VPC", so internet-bound traffic goes to the IGW.
- Explicit association makes only these two subnets public.

## Step 2: Private route table

**Console:** Create route table → Name `private-rt`, VPC `kesari-vpc`, tag `Project=aws-practice` → Create.
- Do **not** add any routes. It keeps just the `local` route.
- **Subnet associations** → tick **pvt-a** and **pvt-b** → Save.

**Why:**
- With no `0.0.0.0/0` route, private subnets have no path to or from the internet, even if a security group is misconfigured.
- Explicit association stops them from falling back to the main route table. If someone ever edits the main table, your private subnets stay safe.

## Step 3: Auto-assign public IPv4 on public subnets

**Console:** VPC → Subnets → select **pub-a** → Actions → **Edit subnet settings** → tick **Enable auto-assign public IPv4 address** → Save. Repeat for **pub-b**. Leave pvt-a and pvt-b unticked.

**Why:**
- A public IP is the third requirement for internet reachability. The IGW translates between the public IP and the instance's private IP.
- Doing it at subnet level means future web servers get a public IP automatically, and private ones never do.

## The three things that make a subnet public

1. IGW attached (done).
2. Route `0.0.0.0/0 → IGW` in the subnet's route table.
3. Instances get a public IPv4.

## Then verify

Run the `describe-route-tables` command from earlier and paste the output. If your PowerShell variables ($PUBA etc.) were never set to real subnet IDs, no problem, since the Console doesn't need them.

*SAP-C03 relevance: IGW + route + public IP as the three conditions for internet access is a common troubleshooting pattern.*

---

**You** (21 Nov 2026, 12:37 am)

for private do we don't need to attach any routing policy or what or just default is enough

---

**Tutor** (21 Nov 2026, 12:37 am)

## Default is enough: the local route is all the private subnets need

You don't add any routing policy for private subnets at this level. Every route table gets the `local` route automatically (`10.20.0.0/16 → local`), and that's exactly what you want.

**What local gives you**
- pvt-a and pvt-b can talk to each other and to pub-a and pub-b inside the VPC.
- That's how your future web server will reach the database.
- Security groups and NACLs still decide what is actually allowed.

**What you deliberately leave out**
- No `0.0.0.0/0` route, so there's no path to or from the internet.
- The customer's requirement is "nothing in the private layer should ever be reachable from the internet." No route is the strongest way to guarantee that.

**Why we still create `private-rt` and don't rely on the main route table**
- Your VPC's main route table is also local-only today, so private subnets would work without it.
- But the main table is a fallback. If someone later adds an IGW route to it, every subnet using it becomes public by accident.
- An explicit `private-rt` associated with pvt-a and pvt-b protects against that, and it's what the checklist expects.

**When you would add routes later (not now)**
- Outbound internet for updates: `0.0.0.0/0 → NAT Gateway` (about $0.056/hr, ~$41/month, so not at this level).
- Private access to S3: a gateway endpoint (free), but the brief says no endpoints for now.
- Other VPCs or the office: peering, TGW or VPN routes (later levels).

**Console recap for private**
1. Create route table `private-rt` in `kesari-vpc`, tag `Project=aws-practice`.
2. Leave routes alone (only `local`).
3. Subnet associations → pvt-a and pvt-b.

**Verify**

```powershell
aws ec2 describe-route-tables --region ap-south-1 --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "RouteTables[].{name:Tags[?Key=='Name']|[0].Value,routes:Routes[].[DestinationCidrBlock,GatewayId],subnets:Associations[].SubnetId}"
```

Expected for `private-rt`: only `10.20.0.0/16 → local`, with the two private subnet IDs.

**Cost:** $0.

*SAP-C03 relevance: "private subnet = no IGW route; add NAT only if outbound internet is required" is a standard design principle.*

---

**You** (21 Nov 2026, 12:39 am)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-route-tables --region ap-south-1 --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "RouteTables[].{name:Tags[?Key=='Name']|[0].Value,routes:Routes[].[DestinationCidrBlock,GatewayId],subnets:Associations[].SubnetId}"
>> 
[                                                                                                                                                            
    {
        "name": null,
        "routes": [
            [
                "10.20.0.0/16",
                "local"
            ]
        ],
        "subnets": []
    },
    {
        "name": null,
        "routes": [
            [
                "10.20.0.0/16",
                "local"
            ],
            [
                "0.0.0.0/0",
                "igw-0dae1d4a59f8bad33"
            ]
        ],
        "subnets": [
            "subnet-07413f862270facde",
            "subnet-0aad1bf4f1643e900"
        ]
    },
    {
        "name": "private-rt",
        "routes": [
            [
                "10.20.0.0/16",
                "local"
-- More  --

---

**Tutor** (21 Nov 2026, 12:39 am)

## Partial view, but it looks right so far

Your output got cut off at `-- More --` (PowerShell's pager). Press **q** to exit it, or add `--no-cli-pager` to the command. I can see three route tables so far:

| Table | Routes | Subnets | Verdict |
|---|---|---|---|
| Unnamed #1 | `local` only | none | This is the VPC's automatic **main** route table. Correct, leave it alone. |
| Unnamed #2 | `local` + `0.0.0.0/0 → igw-0dae...` | 2 subnets | This is your public route table. Routes are correct, but it has **no Name tag**. |
| `private-rt` | `local` ... (cut off) | not visible yet | Need to see the rest. |

## Fixes and checks

**1. Name (and tag) the public route table.** Console: Route tables → select it → Tags → add `Name=public-rt` and `Project=aws-practice`. Or use the CLI (find its ID first):

```powershell
aws ec2 describe-route-tables --region ap-south-1 --no-cli-pager --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "RouteTables[].{id:RouteTableId,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
```

```powershell
aws ec2 create-tags --region ap-south-1 --resources <public-rt-id> --tags Key=Name,Value=public-rt Key=Project,Value=aws-practice
```

**2. Tag the main route table too** (`Name=main-rt`, `Project=aws-practice`). The brief says every route table needs the tags, and the main one is created automatically without them.

**3. Confirm the two public associations.** The IDs `subnet-07413f86...` and `subnet-0aad1bf4...` must be **pub-a** and **pub-b**, not pvt-a or pvt-b. Check:

```powershell
aws ec2 describe-subnets --region ap-south-1 --no-cli-pager --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "Subnets[].{id:SubnetId,name:Tags[?Key=='Name']|[0].Value,publicIp:MapPublicIpOnLaunch}"
```

**4. Check `private-rt`.** It must show only `10.20.0.0/16 → local` and the IDs of pvt-a and pvt-b. Re-run the route-table command with `--no-cli-pager` and paste the full output.

**5. Auto-assign public IPv4.** In the subnet output above, `publicIp` should be `true` only for pub-a and pub-b. If it's still `false`, do Step 3 from the console recap (Edit subnet settings).

**Cost:** $0.

## Next

Once the route tables and subnet flags check out, we move to security groups (web SG and private SG) and then the private NACL.

*SAP-C03 relevance: knowing the main route table is the implicit fallback for unassociated subnets, and why you associate explicitly, is a common exam point.*

---

**You** (21 Nov 2026, 12:40 am)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-route-tables --region ap-south-1 --no-cli-pager --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "RouteTables[].{id:RouteTableId,name:Tags[?Key=='Name']|[0].Value,project:Tags[?Key=='Project']|[0].Value}"
>> 
[
    {
        "id": "rtb-0b62e57c87ab7598c",
        "name": null,
        "project": null
    },
    {
        "id": "rtb-0095cef0119e5d1a1",
        "name": null,
        "project": "aws-practice"
    },
    {
        "id": "rtb-07a525b73b5d086cb",
        "name": "private-rt",
        "project": "aws-practice"
    }
]

---

**Tutor** (21 Nov 2026, 12:40 am)

## Which is which

| ID | Role | Tags now | Needs |
|---|---|---|---|
| `rtb-0b62e57c87ab7598c` | Main route table (local only, no subnets) | none | `Name=main-rt`, `Project=aws-practice` |
| `rtb-0095cef0119e5d1a1` | Public (has the IGW route, 2 subnets) | Project only | `Name=public-rt` |
| `rtb-07a525b73b5d086cb` | `private-rt` | both | nothing |

I'm matching these to the earlier output by the order they appeared, so the first two matches are an inference. The next command confirms them.

## Fix the tags

```powershell
aws ec2 create-tags --region ap-south-1 --resources rtb-0095cef0119e5d1a1 --tags Key=Name,Value=public-rt
aws ec2 create-tags --region ap-south-1 --resources rtb-0b62e57c87ab7598c --tags Key=Name,Value=main-rt Key=Project,Value=aws-practice
```

## Still to confirm: private-rt and the subnet flags

Your last output was cut off before showing `private-rt`'s routes and associations. Run this with the pager off:

```powershell
aws ec2 describe-route-tables --region ap-south-1 --no-cli-pager --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "RouteTables[].{name:Tags[?Key=='Name']|[0].Value,routes:Routes[].[DestinationCidrBlock,GatewayId],subnets:Associations[].SubnetId}"
```

```powershell
aws ec2 describe-subnets --region ap-south-1 --no-cli-pager --filters Name=vpc-id,Values=vpc-05d1495f13b08e8fc --query "Subnets[].{id:SubnetId,name:Tags[?Key=='Name']|[0].Value,publicIp:MapPublicIpOnLaunch}"
```

Check these:
- `public-rt` is associated with the IDs of **pub-a** and **pub-b** (`subnet-07413f86...` and `subnet-0aad1bf4...` should map to those names).
- `private-rt` has only `10.20.0.0/16 → local`, and its subnets are **pvt-a** and **pvt-b**.
- `publicIp` is `true` only for pub-a and pub-b.

Paste both outputs and I'll confirm. Once they're right, you can tick the route table box and we move to security groups.

**Cost:** $0.

*SAP-C03 relevance: consistent tagging on auto-created resources (like the main route table) matters for tag-based cost allocation and cleanup.*

---

**You** (21 Nov 2026, 12:40 am)

I'll delete everything now

---

**Tutor** (21 Nov 2026, 12:40 am)

## Before you delete: Level 2 isn't finished

You've built the VPC, subnets, IGW and route tables, but these are still open:
- Web SG and private SG (SG-to-SG reference)
- Custom NACL on the private subnets
- The Security Group vs NACL explanation, which Meghna asked for directly
- The optional live test

Everything built so far costs **$0**, so there's no cost pressure to delete now. Your rule is to delete the same day, so:
- **Option 1 (recommended):** do the SGs and NACL first (about 15 minutes), then delete everything. This is the part that gets tested in interviews.
- **Option 2:** delete now and learn SGs/NACLs during the Terraform rebuild. That's workable, but you'd be writing code for concepts you haven't seen in the Console yet.

## Delete order (if you go ahead)

Dependencies matter: you can't delete a VPC while anything is still inside it. Don't touch the default VPC (`vpc-011c6227ea559561e`).

```powershell
$R = "ap-south-1"
$VPC = "vpc-05d1495f13b08e8fc"
$IGW = "igw-0dae1d4a59f8bad33"

# 1. Check for instances (should be empty)
aws ec2 describe-instances --region $R --no-cli-pager --filters Name=vpc-id,Values=$VPC Name=instance-state-name,Values=pending,running,stopping,stopped --query "Reservations[].Instances[].InstanceId"

# 2. Route table associations: deleting the subnets in step 4 also removes them, but custom route tables must be deleted by ID
# 3. Detach and delete the IGW
aws ec2 detach-internet-gateway --region $R --internet-gateway-id $IGW --vpc-id $VPC
aws ec2 delete-internet-gateway --region $R --internet-gateway-id $IGW

# 4. Delete subnets
aws ec2 describe-subnets --region $R --no-cli-pager --filters Name=vpc-id,Values=$VPC --query "Subnets[].SubnetId" --output text | ForEach-Object { $_ -split "\s+" } | ForEach-Object { aws ec2 delete-subnet --region $R --subnet-id $_ }

# 5. Delete the custom route tables (public-rt, private-rt). Leave the main one, it goes with the VPC.
aws ec2 delete-route-table --region $R --route-table-id rtb-0095cef0119e5d1a1
aws ec2 delete-route-table --region $R --route-table-id rtb-07a525b73b5d086cb

# 6. Delete any custom SGs / NACLs you created (the default ones go with the VPC)
aws ec2 describe-security-groups --region $R --no-cli-pager --filters Name=vpc-id,Values=$VPC --query "SecurityGroups[?GroupName!='default'].[GroupId,GroupName]"
aws ec2 describe-network-acls --region $R --no-cli-pager --filters Name=vpc-id,Values=$VPC --query "NetworkAcls[?IsDefault==``false``].NetworkAclId"

# 7. Delete the VPC
aws ec2 delete-vpc --region $R --vpc-id $VPC
```

If step 6 lists anything, delete it with `delete-security-group --group-id ...` or `delete-network-acl --network-acl-id ...` before step 7. If SGs reference each other, delete the private SG first, then the web SG.

If any step fails with `DependencyViolation`, paste the error and I'll tell you what's still attached.

## Confirm it's clean

```powershell
aws ec2 describe-vpcs --region $R --no-cli-pager --filters Name=tag:Project,Values=aws-practice
aws ec2 describe-instances --region $R --no-cli-pager --filters Name=instance-state-name,Values=running,stopped
aws ec2 describe-addresses --region $R --no-cli-pager
aws ec2 describe-nat-gateways --region $R --no-cli-pager --filter Name=state,Values=available
```

All four should come back empty.

**Cost:** $0 before and after.

*SAP-C03 relevance: knowing the teardown order (instances, then IGW, subnets, route tables, SGs, VPC) is the same dependency logic Terraform resolves for you on `destroy`.*

---

**You** (21 Nov 2026, 12:42 am)

[]
[]
[]
PS C:\Users\asgha\Desktop\AWS\Customer Cases\L1 Chai Website> aws ec2 describe-vpcs --region $R --no-cli-pager --filters Name=tag:Project,Values=aws-practice
>> aws ec2 describe-instances --region $R --no-cli-pager --filters Name=instance-state-name,Values=running,stopped
>> aws ec2 describe-addresses --region $R --no-cli-pager
>> aws ec2 describe-nat-gateways --region $R --no-cli-pager --filter Name=state,Values=available
>> 
{
    "Vpcs": []
}
{
    "Reservations": []
}
{
    "Addresses": []
}
{
    "NatGateways": []
}

---

**Tutor** (21 Nov 2026, 12:42 am)

## Clean delete confirmed

- No VPC tagged `Project=aws-practice`, no instances, no Elastic IPs, no NAT Gateways.
- The VPC delete only succeeds when nothing is left inside it, so the custom route tables, IGW and subnets are gone too.
- Leftover cost: **$0**. Nothing you built was billed anyway.
- Tick the "Clean delete" box. Leave the SG and NACL boxes unticked, because you never built those in the Console.

## What Level 2 still owes you

Be upfront with yourself about these gaps, since interviewers probe exactly here:
- Web SG and private SG (inbound from the web SG by reference, not by CIDR).
- Custom NACL on the private subnets.
- The optional live test.
- Explaining SG vs NACL to Meghna.

## SG vs NACL in a few lines

| | Security Group | NACL |
|---|---|---|
| Level | Instance/ENI | Subnet |
| State | **Stateful**: return traffic is automatic | **Stateless**: you must allow return traffic yourself (ephemeral ports 1024-65535) |
| Rules | Allow only | Allow and deny |
| Evaluation | All rules together | In rule-number order, first match wins |
| Source | Can reference another SG | CIDR only |
| Default | Deny all in, allow all out | Default NACL allows all; a new custom NACL denies all |

Plain-English version for Meghna: the NACL is the gate on the private street, and the SG is the lock on each door. Both must agree before traffic gets in.

## Next: the Terraform rebuild (about 1 hour)

Suggested order:
1. `provider` block with `default_tags { tags = { Project = "aws-practice" } }`. This tags everything automatically, including the main route table that bit you today.
2. `aws_vpc`, then four `aws_subnet` resources (try `for_each` or `count`).
3. `aws_internet_gateway`, two `aws_route_table` resources, and `aws_route_table_association` for each subnet.
4. `aws_security_group` for web and private, using `referenced_security_group_id` in the private SG's ingress rule.
5. `aws_network_acl` associated with the private subnets, plus the ephemeral-port outbound rule.
6. `terraform destroy`, then rerun the clean-delete checks.

Don't commit `.terraform/` or `*.tfstate` to Git. Add a `.gitignore` first.

Want me to start with step 1? I'll give you only the provider block and one `aws_vpc` resource, and you write the rest.

Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

*SAP-C03 relevance: stateful vs stateless filtering, and SG-to-SG references vs CIDR rules, appear in many network-isolation questions.*


---

## Level 3: Private server, no SSH, no NAT

Phase: done. Hints used: 0.

**Customer:** Meenakshi Sundaram, Head of IT, Kovai Weaves Pvt Ltd (cotton yarn and fabric manufacturer, Coimbatore)

> We are a 300-person textile mill in Coimbatore, and last month a contractor left port 22 open to the whole internet on our inventory server. Our logs showed thousands of brute-force login attempts from abroad, and we still cannot say for sure who logged in or what they ran. My auditors want a server that nobody can reach from the internet, no shared SSH keys at all, and a record of every admin session. We are a small team on a tight budget, so I do not want to pay for expensive network boxes just to let a server talk to AWS.

**Requirements**
- Functional: Our admins must be able to open a shell on the inventory server from their laptops (AWS CLI) or the AWS Console without SSH, without key pairs, and without any bastion host.
- Security: The server must sit in a private subnet with no public IP and no inbound rules on its security group. It must get its AWS permissions from an IAM instance role, never from stored access keys.
- Security/Audit: We need to know who did what on the server, and those records must be kept somewhere safe.
- Cost: The server must reach the AWS services it needs privately, without a NAT Gateway. Show me which private connections cost money and which are free, and keep only what is truly needed.
- Resilience: If the server is terminated and replaced, admins must be able to connect again within minutes, with no keys to redistribute and no manual network changes.

**Constraints**
- Build everything by hand in the AWS Console first and verify with the AWS CLI. Destroy it the same day, then rebuild it in Terraform, time-boxed to about 1 hour.
- Region: ap-south-1 (Mumbai) only.
- Total cost cap for the whole exercise (build, test, destroy in one sitting): USD 1.00.
- Instance type: t3.micro or t4g.micro (Free-plan eligible), 8 GB gp3 root volume, Amazon Linux 2023 (SSM Agent preinstalled).
- No NAT Gateway, no NAT instance, no Elastic IP, no public IPv4 address, and no internet gateway route from the private subnet.
- Create interface endpoints in one AZ/subnet only (lab setting) and delete them immediately after testing.
- Tag every resource Project=aws-practice.
- Do not use AWS Organizations or Control Tower. Do not use Direct Connect.
- Never create root access keys. Never commit keys or Terraform state to Git.

**Acceptance tests**
- [x] aws ec2 describe-instances --region ap-south-1 --filters Name=tag:Project,Values=aws-practice --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,IamInstanceProfile.Arn,SubnetId]' shows PublicIpAddress = null and an instance profile attached. The subnet's route table has no 0.0.0.0/0 route.
- [x] aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[].IpPermissions' returns [] for the instance security group.
- [x] aws ssm describe-instance-information --region ap-south-1 shows the instance with PingStatus = Online.
- [x] aws ssm start-session --target <instance-id> --region ap-south-1 (Session Manager plugin installed locally) opens a shell. Running curl -m 5 https://www.google.com inside the session times out, proving there is no internet path.
- [x] Inside the session, aws s3 ls s3://<your-log-bucket> succeeds over the S3 gateway endpoint. aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[].[ServiceName,VpcEndpointType,State]' shows the S3 endpoint as Gateway and the ssm/ssmmessages/ec2messages endpoints as Interface, all available.
- [x] After you end a session, its transcript appears in the S3 log bucket. The bucket has Block Public Access fully on and default encryption enabled.
- [x] Terminate the instance and launch a replacement from the same settings (role, subnet, security group). It shows Online in Session Manager within about 5 minutes with no extra changes.
- [x] Clean delete: aws resourcegroupstaggingapi get-resources --region ap-south-1 --tag-filters Key=Project,Values=aws-practice returns nothing. aws ec2 describe-vpc-endpoints and aws ec2 describe-instances (excluding terminated) return no lab resources, and aws ec2 describe-addresses is empty.

**Customer facts (hidden during the exercise)**
- audit_meaning: By 'who did what' I mean the full command transcript of every session, tied to the person's IAM identity, kept in an S3 bucket we own. CloudWatch Logs is nice but not required for now. The S3 transcript is what the auditors asked for.
- budget: For this proof of concept I'll approve under USD 1 for the test. In production, our monthly AWS budget for this server is about USD 40, so a NAT Gateway at around USD 40+ a month is out of the question.
- data_sensitivity: The server holds yarn stock levels, supplier prices and customer purchase orders. That is commercially confidential but not personal health or card data, so no PCI. Encryption at rest is still expected.
- growth: If this works, we will move 4 more internal servers (payroll, ERP, two file servers) the same way over the next 6 months, all in Mumbai.
- log_retention: The auditors want session logs kept for 1 year. For this pilot, just show me where a lifecycle rule would go. You don't need to wait a year.
- resilience_expectation: It is a single internal server. If it dies, we accept about 30 minutes of downtime (RTO 30 min), and losing up to a day of changes is fine for now (RPO 24 hours). Rebuilding it must not need new keys or network changes.
- team_skills: My team knows Linux well but is new to AWS. They are used to PuTTY and SSH keys, so it has to be simple: a single command or a click in the console.
- traffic: About 20 internal users and under 1 GB of data a day. This is not customer-facing, and no load balancer is needed.
- what_server_needs_to_reach: The server only needs to pull our app packages and config files from an S3 bucket and talk to Systems Manager. It does not need the public internet. OS patches can wait for a later phase.
- who_needs_access: Only three admins in our Coimbatore office need shell access, plus one vendor engineer in Chennai about once a month. Every one of them must use their own named IAM identity, never a shared login.

### My notes

--- from Tutor ---
## Build plan: Level 3 (Console first, then CLI checks)

Before you start, send Meenakshi a short summary and the cost estimate she asked for. She said she wants the cost before you go ahead. Something like: "Test build under USD 1, production about USD 31-33/month, no NAT. Admins and vendor get named logins, every session is recorded for 1 year."

Tag **every** resource `Project=aws-practice`. Region **ap-south-1** only. Work in one sitting (about 1.5-2 hours).

### Phase 0: Prep (10 min, $0)
- Sign in as an IAM user or admin role, **not root**. Never create root access keys.
- Install the AWS CLI and the **Session Manager plugin** on your laptop. Check with `aws sts get-caller-identity`.
- Check you have a **default VPC or create a new one** (step 1).

### Phase 1: Network, no internet path (15 min, $0)
1. Create a **VPC** (e.g. 10.20.0.0/16) with DNS hostnames and DNS resolution **enabled**. Interface endpoints need this for private DNS.
2. Create **one private subnet** in one AZ (e.g. ap-south-1a).
3. Create a **route table** for it. Keep only the `local` route. **No internet gateway, no NAT, no 0.0.0.0/0.**
4. Create two security groups:
   - `ec2-sg`: **no inbound rules**. Outbound: leave default for now.
   - `endpoint-sg`: inbound **TCP 443 from `ec2-sg`**.

### Phase 2: Buckets (10 min, ~$0)
1. **Session-log bucket** with Block Public Access fully on, default encryption on (SSE-S3 is fine), and a lifecycle rule to expire objects after **365 days**.
2. Think about whether CloudTrail needs its own bucket. A separate one is cleaner. Create the trail **last**, once the rest works.

### Phase 3: IAM (20 min, $0)
1. **Instance role** (trusted entity: EC2) with:
   - the managed policy `AmazonSSMManagedInstanceCore`
   - a small custom policy: `s3:PutObject` on the log bucket only (add read on your app/config prefix later if you have one).
   - Console creates the instance profile for you.
2. **Admin group** `kovai-admins`: allow `ssm:StartSession` on this instance (use a tag condition or the instance ARN), plus `ssm:TerminateSession` for their own sessions. Add one test IAM user with MFA.
3. **Vendor**: leave this for Phase 7. Get the basics working first.

### Phase 4: Server (10 min, ~$0.01/hr)
1. Launch **t4g.micro** (or t3.micro), **Amazon Linux 2023** (match the architecture: arm64 for t4g), 8 GB gp3.
2. Pick your private subnet and `ec2-sg`. **Auto-assign public IP: disable.** **No key pair.**
3. Attach the instance profile. Add the tag.

At this point the server **will not** show up in Systems Manager yet. That is expected. It can't reach AWS. Work out why before the next phase.

### Phase 5: Endpoints (15 min, ~$0.033/hr for the 3 interface ones)
1. Create the **S3 gateway endpoint** and attach it to your route table. Free.
2. Create three **interface endpoints** in your one subnet, with `endpoint-sg` and **Private DNS enabled**:
   - `com.amazonaws.ap-south-1.ssm`
   - `com.amazonaws.ap-south-1.ssmmessages`
   - `com.amazonaws.ap-south-1.ec2messages`
3. Wait 2-5 minutes, then run `aws ssm describe-instance-information`. You want `PingStatus = Online`.

⚠️ From here the meter runs on the endpoints. **Don't walk away.** Finish and delete the same day.

### Phase 6: Session logging (10 min, $0)
1. In Systems Manager, open **Session Manager → Preferences** and enable **S3 logging** to your log bucket.
2. Open a session, run a few commands, and exit. Check that a transcript appears in the bucket.

### Phase 7: Vendor restriction (20 min, $0)
1. Create the custom Session document (one small command, like viewing logs).
2. Create the vendor user with a policy limited to **this instance** and **that document ARN** only. Require MFA.
3. Test: can he open a full shell? He shouldn't be able to.

### Phase 8: Verify, replace, delete (20 min)
1. Walk through your acceptance checklist, one tick at a time. Don't tick anything you haven't run.
2. **Terminate** the instance, launch a replacement with the same role, subnet and security group, and time how long until it shows Online.
3. **Delete in this order:** instances, interface endpoints (stops the biggest cost), gateway endpoint, then buckets (empty them first), IAM, subnet, route table, security groups, VPC.
4. Run the cleanup checks: `aws resourcegroupstaggingapi get-resources ...` and `aws ec2 describe-addresses`.

### Notes
- **Leave out** the backup setup and CloudTrail trail if time is short. Mention them in the design. They are cheap, but they are extra and have cleanup steps.
- Common gotchas: DNS settings off on the VPC, `endpoint-sg` not allowing 443 from `ec2-sg`, and a missing instance profile.

### Your first step
Do Phase 1 now. When the VPC, subnet, route table and two security groups exist, tell me what the route table looks like, and we'll move on. If something fails, paste the error here.

**Exam relevance (SAP-C03):** this is the standard "private instances without NAT" pattern, and it shows up in many scenario questions.

Docs: https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html

### Customer and interviewer chat

**You** (21 Nov 2026, 10:54 am)

I can understnad your probelm we will move your server in private subnet with no 22 port open

---

**Meenakshi Sundaram** (21 Nov 2026, 10:54 am)

Thank you, that is exactly what my auditors want to hear, no port 22 open to anyone. But my admins are used to PuTTY and keys, so I'd like to know how they will actually get in, and how we will know who did what. Do you have any questions for me about our setup, the users or the budget before you start planning?

---

**You** (21 Nov 2026, 10:56 am)

how about costing

---

**Meenakshi Sundaram** (21 Nov 2026, 10:56 am)

Good question. For this test I can approve under USD 1 in total. Once it is in production, our monthly AWS budget for this server is about USD 40, so a NAT Gateway at USD 40+ a month is out of the question. I don't want to pay for expensive network boxes just to let one server talk to AWS.

---

**You** (21 Nov 2026, 10:57 am)

How many admins are there, and how do they sign in to AWS today (IAM users, or something else)?
Should every admin have the same access, or should some be read-only?
How long must session records be kept (for example, 1 year for auditors)?
Does the inventory server need to talk to any other AWS service besides S3?
What should happen if the server dies: how fast must admins be able to get back in?

---

**Meenakshi Sundaram** (21 Nov 2026, 10:57 am)

Happy to answer, ji. We have three admins in the Coimbatore office, plus one vendor engineer in Chennai who needs access about once a month. Today they all use PuTTY with a shared key, which is the problem. For AWS, I want each person to have their own named login, never a shared one.

The three of ours should get the same access. I would like the vendor to be more restricted, since he is outside our company, but I'm leaving it to you to suggest how.

The auditors want session records kept for 1 year. The server only needs to pull app packages and config files from our S3 bucket and talk to Systems Manager, nothing on the public internet.

If the server dies, we can accept about 30 minutes of downtime and losing up to a day of changes. But rebuilding must not need new keys or network changes.

---

**You** (21 Nov 2026, 11:54 am)

A custom session document can restrict him to specific commands instead of a full shell. you want to do anything like this

---

**Meenakshi Sundaram** (21 Nov 2026, 11:54 am)

I don't understand the technical part, but if it means the vendor can only do the few things he needs, then yes, I would like that. He comes once a month to check the application, look at its logs and restart the service if needed. He has no reason to browse our stock data or supplier prices, and I'm not comfortable giving him full control of the server. What I do need is that every command he runs is on record for the auditors. How you achieve that is your job, ji.

---

**You** (21 Nov 2026, 11:57 am)

Yes we will restrict the vendor,
what is rto and rpo

---

**Meenakshi Sundaram** (21 Nov 2026, 11:57 am)

Ji, I only know these in business terms. RTO is how long we can sit without the server before it hurts us, and for us that is about 30 minutes. RPO is how much recent work we can afford to lose, and for us that is up to one day of changes. So the server must be back quickly, and a day-old copy of our data is acceptable. How you arrange that is your job, but please tell me what it will cost.

---

**You** (21 Nov 2026, 11:57 am)

so we will daily backing up your resources

---

**Meenakshi Sundaram** (21 Nov 2026, 11:57 am)

Yes ji, a daily backup sounds right to me, since a day of lost changes is acceptable. But please keep it cheap, because the data is under 1 GB a day and our whole budget for this server is about USD 40 a month. Also, the rebuilt server must come back without new keys or network changes, so will the backup alone be enough for that? I'd like you to tell me what it will cost before you go ahead.

---

**Coach** (21 Nov 2026, 12:19 pm)

[Coach] Your best question was whether the server needs anything besides S3. It decides which private connections you build and what they cost, and your RTO/RPO question was a close second.

Here are the questions you missed:

1. **What exactly does "who did what" mean to the auditors?** Is it API activity such as who opened a session, or the full transcript of every command? You suggested CloudTrail event history, but that only shows who started a session, not what they typed. The answer decides whether you need session logging to S3, and it affects the vendor's restricted access too.
2. **How sensitive is the data, and is encryption expected?** This decides whether default S3 encryption is enough, whether you need customer-managed keys, and whether the session logs and backups need stricter access. Customer-managed keys could also add an endpoint cost.
3. **Will you move more servers later?** If more servers follow, you would design the VPC, subnets and endpoints so they can be shared, instead of rebuilding each time. It also changes the production cost per server.
4. **Does the server ever need the internet, for example for OS patches?** If yes, you have to plan a cheaper alternative to NAT. If not, you can keep the design fully private and defer patching explicitly.
5. **How comfortable is the team with AWS, and how must they connect?** They know PuTTY and SSH keys. If access has to be a single command or a console click, that shapes how you document and set up named IAM logins.

Next, send Meenakshi a short cost summary and confirm the log meaning with her, then start Phase 1 of the build plan: the VPC, one private subnet with no internet route, and the two security groups.

---

**Interviewer** (24 Nov 2026, 1:45 pm)

Switching to **interviewer** mode.

Walk me through:
1. Your architecture (what you built and why)
2. The hardest problems you hit and how you fixed them
3. What it cost and how you kept it low

Then I'll ask **4 questions**, one at a time.

---

**You** (24 Nov 2026, 1:49 pm)

So bascially I created private vpc based arch where my ec2 instance is gettinng accesed by only ssm which I added by using the endpoints interfaces so my whole network will be private subnet and logs of access is stored in s3 bucket

hardest problem I hit is adding the ssm interface and configuring logging to s3 bucket 
it will cost very little main cost will be interfaces and for s3 data

---

**Interviewer** (24 Nov 2026, 1:49 pm)

Thanks. That's a reasonable start, but in a real interview it's too high-level. "Very little" cost and "it was hard" won't land. Interviewers want **specific endpoint names, specific symptoms, and real dollar figures**. Keep that in mind for the next answers.

**Q1/4: Why X over Y**

You said the instance is reached "only by SSM, using interface endpoints."

- **Exactly which interface endpoints** did you create, and what does each one do? What breaks if you leave one out?
- For S3 you used a **gateway** endpoint, not an interface endpoint. Why? Give me at least two concrete differences between the two types, including cost.

---

**You** (24 Nov 2026, 1:51 pm)

I created 3 total ssm interfaces I forgot the names can you exxplain me 
gateway sits in public domain maybe

---

**Interviewer** (24 Nov 2026, 1:51 pm)

I can't hand you the answers mid-interview. In a real one, "I forgot" plus a guess counts against you. But you can **reason your way there**, and that's what interviewers want to see.

**On the three interface endpoints:** all three names start with `ssm` or end in `messages`. Think about what Session Manager has to do:
- The agent has to **register and talk to the Systems Manager API**.
- It has to **open a live shell channel** for your session.
- It has to **receive commands/messages** from the service.

Try to name the three from those jobs. Then tell me **what symptom you'd see** if one were missing. For example, does the instance still show `Online`, or does `start-session` fail?

**On the gateway endpoint:** that's not right. It does **not** sit in the public domain, and S3 traffic through it never touches the internet. Hint: one endpoint type shows up as a **network interface (ENI) with a private IP in your subnet**. The other shows up somewhere else you configured in Phase 1. Where?

Give me:
1. The three endpoint names (best attempt) and what breaks without each.
2. **Where** a gateway endpoint lives vs an interface endpoint.
3. **Cost** of each type. Your brief lists it.

---

**You** (24 Nov 2026, 1:55 pm)

used three interface endpoints (ssm, ssmmessages, ec2messages) in one AZ, about

---

**Interviewer** (24 Nov 2026, 1:55 pm)

You have the **names** right: ssm, ssmmessages, ec2messages. But that line was cut off mid-sentence, and it reads like the line from your tutor notes. In a real interview you won't have notes, so I need **your own words**.

You still haven't answered most of Q1. Give me short answers to these three:

1. **Failure symptoms:** You delete **only ssmmessages**. Does the instance still show `PingStatus = Online`? What happens when you run `start-session`? Then do the same for **ssm** alone.
2. **Where each type lives:** An interface endpoint is an ENI with a private IP in your subnet. Where does the S3 **gateway** endpoint show up? Think about what you saw in Phase 1 resources, not the subnet.
3. **Cost, in numbers:** Roughly what does one interface endpoint cost per hour per AZ, and what did your three cost per hour? What does the gateway endpoint cost?

One or two lines each is enough. Real numbers, not "very little."

---

**You** (24 Nov 2026, 1:59 pm)

so cost of one interface is roughly 0.011 so for 3 it will 0.033
inteface in private subnet and gateay in route table
when someone delete ssm messages start sessoin won't work but ping status will be online

---

**Interviewer** (24 Nov 2026, 2:00 pm)

Better. Those are concrete. **Location** (ENI in the subnet vs route table entry) and the **ssmmessages** symptom ("Online, but no shell") are correct, and $0.011/hr per endpoint is the right number.

Two gaps an interviewer would note:
- You skipped **ssm deleted alone**. What happens to PingStatus then?
- You didn't give the **gateway endpoint's cost**, or the per-GB charge on interface endpoints.

Add both to your revision notes. Moving on.

**Q2/4: 10x scale and cost**

Meenakshi is happy. Next year Kovai wants **10 servers**, and for resilience they must run across **2 AZs** in production.

1. What happens to your **interface endpoint cost per month** when you go from 1 AZ to 2 AZs? Give a rough number.
2. Does that cost go up when you go from **1 server to 10 servers** in the same VPC? Why or why not?
3. Is a **NAT Gateway** cheaper at that point? Compare it in numbers against your endpoints.

Short answers, real numbers.

---

**You** (24 Nov 2026, 2:01 pm)

ssm deletd alone no ping status 
gateway endpoint's cost it is 0

---

**Interviewer** (24 Nov 2026, 2:01 pm)

Good. Both are correct:
- **ssm deleted alone:** the agent can't check in, so the instance drops out of Online. In an interview, add the **status name** and the **error `start-session` returns**. That's the detail that impresses.
- **Gateway endpoint:** **$0**. Also mention that interface endpoints charge per GB processed on top of the hourly fee.

Q1 closed. Now back to the open question.

**Q2/4: 10x scale and cost** (still unanswered)

Kovai grows to **10 servers** across **2 AZs** in production.

1. **1 AZ to 2 AZs:** What happens to your three interface endpoints' **monthly** cost? Hint: roughly 730 hours in a month. Give me a number.
2. **1 server to 10 servers** in the same VPC: does the endpoint cost go up? Why or why not?
3. **NAT Gateway comparison:** At that point, is a NAT Gateway cheaper or more expensive than your endpoints? Give rough monthly numbers, and say one thing NAT gives you that endpoints don't, and one security downside of NAT.

One or two lines each, with numbers.

---

**You** (24 Nov 2026, 2:03 pm)

Ec2 free tier can't handle so cost will increase 
10 serveers can work in same vpc 
Nat is outbound enabled so userss can access outbound things that is the issue and nat is costly than interfaces

---

**Interviewer** (24 Nov 2026, 2:03 pm)

Partly there, but these answers would not pass a real interview yet.

- **NAT security point:** this is a fair point. A NAT Gateway opens an outbound internet path, which creates a data-exfiltration and malware-download risk. Put it in those words.
- **"NAT is costlier":** I need **numbers**, not a direction.
- **"EC2 free tier can't handle it":** that is true, but I asked about **endpoint** cost, not instance cost.
- **"10 servers can work in the same VPC":** that does not answer the question. I asked whether the **endpoint bill** changes.

Here are three quick follow-ups. Do the math yourself, one line each.

1. **2 AZs:** You have 3 interface endpoints at about $0.011/hr **per endpoint per AZ**, and a month has about 730 hours. What is the monthly cost in **1 AZ**, and what is it in **2 AZs**?
2. **10 servers:** Is an interface endpoint billed **per server** or **per endpoint per AZ**? Based on that, does adding 9 more servers change the hourly endpoint bill? What *does* grow with more servers?
3. **NAT in numbers:** A NAT Gateway costs about $0.056/hr plus about $0.056/GB. For resilience you would want one per AZ. Roughly what is that per month for 2 AZs before any data charges? Is that more or less than your answer to #1?

---

**You** (24 Nov 2026, 2:10 pm)

730*0.011*3 for one and just mutliplie it by 2 for 2 
interfae is per endpoint per az 
no server will not affect bill but new endpoints will

it will be more than inteface but if we want to more conections then nat is better

---

**Interviewer** (24 Nov 2026, 2:10 pm)

Closer. The **method** is right, and so is "per endpoint per AZ, not per server." But a real interviewer would push on three things:

- **Say the number, not the formula.** "730 × 0.011 × 3" makes the interviewer do the math. Give a dollar figure for 1 AZ, 2 AZs, and 2 NATs.
- **"Servers won't affect the bill"** is only half right. One part of the endpoint bill *does* grow with more servers. Which part? (You mentioned it yourself in Q1.)
- **"More connections, then NAT is better"** is imprecise. NAT doesn't care about connections. Say what actually drives the crossover: the number of **distinct AWS services** you need endpoints for, per AZ. Roughly how many before NAT's hourly fee wins?

Put those three in your revision notes. Moving on.

**Q3/4: Failure modes and DR**

Meenakshi gave you **RTO 30 minutes, RPO 1 day**. It's 3 a.m., and the inventory server's instance is gone. Its EBS volume is gone too.

1. **Data:** What exactly gives you the 1-day RPO? Name the service or feature, how often it runs, and roughly what it costs for an 8 GB volume.
2. **Rebuild:** How does a new server come back **within 30 minutes with no manual network changes or keys**? What did you save so you aren't clicking through the console again? Could it be automatic?
3. **Single-AZ risk:** Your three interface endpoints live in **one AZ**. If that AZ has an outage and you launch the replacement in another AZ, can admins still open a session? What would you change for production?

Short answers, with specifics.

---

**You** (24 Nov 2026, 2:11 pm)

ebs snapshots in s3
user data scripts 
I'll add one route 53 end point

---

**Interviewer** (24 Nov 2026, 2:11 pm)

Three one-word answers would not survive a real interviewer. Each one is a starting point, so let's dig in.

**1. "EBS snapshots in S3"**
Snapshots are the right idea, but you won't see them in your S3 bucket. AWS stores them behind the scenes. I still need specifics:
- **What schedules them** so nobody has to remember at 3 a.m.? Name the service.
- **How often**, and **how long you keep them**?
- **Rough cost** for an 8 GB volume. Snapshot storage is about $0.05/GB-month, and only changed blocks are added after the first one.

**2. "User data scripts"**
User data runs a bootstrap script, but on its own it doesn't remember the **role, subnet, security group, AMI or instance type**, and it doesn't restore your **data**.
- What would you save that holds all those launch settings in one place?
- How would the new server get the data back from the snapshot?
- Could replacement happen **automatically**, without anyone launching anything? Which service would watch for the dead instance?

**3. "Route 53 endpoint"**

⚠️ Stop: Route 53 Resolver endpoints are for hybrid DNS between on-premises and AWS. They don't help Session Manager, and they cost about $0.125/hr per IP with a minimum of 2, so roughly $180/month. Your interface endpoints already handle DNS through **Private DNS**. The fix belongs on the **interface endpoints themselves**. Doing it right would cost about $0.033/hr more per extra AZ for your three endpoints, roughly $24/month.

So, in your own words: **what exactly would you change on the three interface endpoints** so a replacement in another AZ can still open a session?

One or two lines each, with names and numbers.

---

**You** (24 Nov 2026, 2:48 pm)

let's stop this interview here I knonw I need to prepare

---

**Interviewer** (24 Nov 2026, 2:48 pm)

## Interview stopped at Q3/4

That's fine. Knowing where your gaps are is the point of this exercise.

### What went well
- You got the **three endpoint names** right, and correctly said an **interface endpoint is an ENI in the subnet** while a **gateway endpoint is a route table entry**.
- You explained the **ssmmessages failure** ("Online, but no shell") correctly.
- You had the right **cost method**: per endpoint, per AZ, per hour, not per server.
- You raised a fair **security point about NAT** (outbound internet path).

### What to prepare before you retry
1. **Lead with specifics.** Use names, status values, error messages and dollar figures. Avoid "very little," "hard," or a formula without the result.
2. **Endpoint cost math.** Have the monthly figures ready for 1 AZ, 2 AZs, and 2 NATs. Know which part of the endpoint bill grows with more servers, and the rough number of services per AZ where NAT's hourly fee becomes cheaper.
3. **Backups (RPO).** Know which service schedules EBS snapshots, how often it runs, how long you keep them, and the rough monthly cost for 8 GB.
4. **Rebuild (RTO).** Know what stores all the launch settings in one place, how data comes back from a snapshot, and which service can replace a dead instance automatically.
5. **Multi-AZ endpoints.** Know what you would change on the interface endpoints themselves for production, and what it adds per month. Drop the Route 53 Resolver idea for this design.

### Tip
Practise answering each one out loud in **2-3 sentences with one number**. That habit alone will lift your score a lot.

When you're ready, you can either:
- **Resume** the interview from Q3/4, or
- Press **Score this level** now. The score will reflect a partial interview.

---

**You** (24 Nov 2026, 2:49 pm)

score tab is off

---

**Interviewer** (24 Nov 2026, 2:49 pm)

## Score button is locked

I don't control the button directly, but it most likely **unlocks only after the interview is complete**, which means after Q4/4 is answered. Stopping at Q3 left it locked.

The quickest way to unlock it: I'll mark **Q3 as incomplete** (it will count against the score), and you answer **one last question**. A short, honest attempt is fine.

**Q4/4: Security and audit**

Meenakshi's auditors ask: *"Prove who did what on the inventory server, and prove nobody can tamper with those records."*

1. **Two different records:** Which service shows **who started a session and when**, and which feature records **what they typed**? Name both.
2. **The vendor:** How do you stop him from opening a full shell while still letting him check logs and restart the app? Name the mechanism, not the details.
3. **Tamper-proofing:** An admin with broad S3 permissions could delete the session logs. Name **one** thing you'd add to the log bucket to prevent that.

One line each is enough. After this, I'll close the interview and the score button should unlock.

---

**Interviewer** (24 Nov 2026, 2:49 pm)

**Scored: 4.5/10.** Full breakdown is in the left panel. Ask me anything about it.

### Tutor chat

**You** (24 Nov 2026, 12:39 pm)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[ServiceName,Groups[].GroupId,SubnetIds]'
>> aws ec2 describe-security-groups --region ap-south-1 --filters Name=tag:Project,Values=aws-practice --query 'SecurityGroups[].[GroupId,GroupName,IpPermissions]'
>> 
[                                                                                                                                                                  
    [
        "com.amazonaws.ap-south-1.s3",
        [],
        []
    ],
    [
        "com.amazonaws.ap-south-1.ssm",
        [
            "sg-08cd8c42fc642459c"
        ],
        [
            "subnet-07a45d18afa034156"
        ]
    ],
    [
        "com.amazonaws.ap-south-1.ssmmessages",
        [
            "sg-08cd8c42fc642459c"
        ],
        [
            "subnet-07a45d18afa034156"
        ]
    ],
    [
        "com.amazonaws.ap-south-1.ec2messages",
        [
            "sg-08cd8c42fc642459c"
        ],
        [
            "subnet-07a45d18afa034156"
        ]
    ]
]
[                                                                                                                                                                  
    [
        "sg-040ab77911d99ca3f",
        "endpoint-sg",
        [
            {
                "IpProtocol": "tcp",
                "FromPort": 443,
                "ToPort": 443,
                "UserIdGroupPairs": [],
                "IpRanges": [
                    {
                        "Description": "web",
                        "CidrIp": "0.0.0.0/0"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": []
            }
        ]
    ]
]
PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ec2 describe-vpc-attribute --region ap-south-1 --vpc-id vpc-006d93adcf21ea3ad --attribute enableDnsSupport                                                                                                            
>> aws ec2 describe-vpc-attribute --region ap-south-1 --vpc-id vpc-006d93adcf21ea3ad --attribute enableDnsHostnames
>> 
{                                                                                                                                                                  
    "EnableDnsSupport": {
        "Value": true
    },
    "VpcId": "vpc-006d93adcf21ea3ad"
}

{                                                                                                                                                                  
    "EnableDnsHostnames": {
        "Value": true
    },
    "VpcId": "vpc-006d93adcf21ea3ad"
}

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH>

---

**Tutor** (24 Nov 2026, 12:40 pm)

## Found it: the endpoints are using the wrong security group

Look at the two IDs:
- The three interface endpoints use **`sg-08cd8c42fc642459c`**.
- Your tagged `endpoint-sg` is **`sg-040ab77911d99ca3f`**.

They are different groups. `sg-08cd...` is almost certainly the VPC **default** SG, which only allows inbound traffic from members of itself. The server is in `ec2-sg`, so its 443 traffic to the endpoints is dropped. That is why the agent can't register, even with Private DNS on.

DNS settings are both `true`, so that suspect is cleared.

### Fix: swap the security group on each endpoint
Do this for `ssm`, `ssmmessages` and `ec2messages`:
- Console: VPC → Endpoints → select endpoint → **Actions → Manage security groups** → add `endpoint-sg`, remove `sg-08cd...` → Save.
- Or CLI (repeat per endpoint ID):
  ```
  aws ec2 modify-vpc-endpoint --region ap-south-1 --vpc-endpoint-id <vpce-id> --add-security-group-ids sg-040ab77911d99ca3f --remove-security-group-ids sg-08cd8c42fc642459c
  ```
  Get the IDs with `aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[].[VpcEndpointId,ServiceName]'`.

### Second problem: the `endpoint-sg` rule is too open
Your rule is TCP 443 from **`0.0.0.0/0`** with description "web". The brief wants this tight, and it's a habit to fix now:
- Delete that rule.
- Add inbound **TCP 443**, source = **`ec2-sg`** (select the security group as the source, not a CIDR).

Order: attach `endpoint-sg` first, then tighten the rule. Opening to `0.0.0.0/0` on a SG inside a private VPC with no internet route is not reachable from outside, but source = `ec2-sg` is the right least-privilege answer and what an interviewer or auditor will look for.

### Then verify
Wait 2-5 minutes (reboot the instance if still empty):
```
aws ssm describe-instance-information --region ap-south-1
```
Expect `PingStatus: Online`.

### Cost
No change: interface endpoints ~$0.033/hr. Still delete them right after your tests.

### Self-check
- Why does the default SG block the server's traffic but `endpoint-sg` (with the right rule) would not?
- What does referencing a security group as a source do that a CIDR doesn't?

**Exam relevance (SAP-C03):** endpoint SG misconfiguration is the classic cause of "managed instance not showing". Reference SGs as sources for least privilege.

Paste the `describe-instance-information` output after the swap.

---

**You** (24 Nov 2026, 12:41 pm)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[].[VpcEndpointId,ServiceName]'
[                                                                                                                                                                  
    [
        "vpce-094a37e0c48dcb545",
        "com.amazonaws.ap-south-1.s3"
    ],
    [
        "vpce-01ec6dc06fec298e5",
        "com.amazonaws.ap-south-1.ssm"
    ],
    [
        "vpce-059714bff2e7e9817",
        "com.amazonaws.ap-south-1.ssmmessages"
    ],
    [
        "vpce-0dcad0778cfddbcbc",
        "com.amazonaws.ap-south-1.ec2messages"
    ]
]

---

**Tutor** (24 Nov 2026, 12:41 pm)

## Good, you have the endpoint IDs

Now swap the security group on the three interface endpoints. Skip the S3 one (`vpce-094a...`): gateway endpoints have no security group.

### Step 1: attach `endpoint-sg` and remove the wrong SG
Run these three commands (PowerShell, one per line):
```
aws ec2 modify-vpc-endpoint --region ap-south-1 --vpc-endpoint-id vpce-01ec6dc06fec298e5 --add-security-group-ids sg-040ab77911d99ca3f --remove-security-group-ids sg-08cd8c42fc642459c

aws ec2 modify-vpc-endpoint --region ap-south-1 --vpc-endpoint-id vpce-059714bff2e7e9817 --add-security-group-ids sg-040ab77911d99ca3f --remove-security-group-ids sg-08cd8c42fc642459c

aws ec2 modify-vpc-endpoint --region ap-south-1 --vpc-endpoint-id vpce-0dcad0778cfddbcbc --add-security-group-ids sg-040ab77911d99ca3f --remove-security-group-ids sg-08cd8c42fc642459c
```
Each should print `{"Return": true}`.

### Step 2: confirm
```
aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[ServiceName,Groups[].GroupId]'
```
All three interface endpoints should now list only `sg-040ab77911d99ca3f`.

### Step 3: tighten the endpoint-sg rule
In the console: EC2 → Security Groups → `endpoint-sg` → Inbound rules → Edit:
- Delete the `0.0.0.0/0` rule (description "web").
- Add: Type HTTPS (TCP 443), Source = the **`ec2-sg`** security group (pick it from the list, not a CIDR).

Do step 1 first, and check that the instance comes Online before tightening. That way, if it fails after tightening, you know the rule is the cause, not the SG swap.

### Step 4: check registration
Wait 2-5 minutes:
```
aws ssm describe-instance-information --region ap-south-1
```
If still empty after 5 minutes, reboot once:
```
aws ec2 reboot-instances --region ap-south-1 --instance-ids i-034eaffd299e9c196
```

### Cost
Interface endpoints are still billing (~$0.033/hr). If you stop for a break before finishing, delete them.

### Self-check
- Why is there no `--security-group-ids` for the S3 endpoint?
- After tightening, which resource must the source of the 443 rule point to?

Paste the output of Step 2 and Step 4.

---

**You** (24 Nov 2026, 12:42 pm)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[ServiceName,Groups[].GroupId]'
>> 
[                                                                                                                                                                  
    [
        "com.amazonaws.ap-south-1.s3",
        []
    ],
    [
        "com.amazonaws.ap-south-1.ssm",
        [
            "sg-040ab77911d99ca3f"
        ]
    ],
    [
        "com.amazonaws.ap-south-1.ssmmessages",
        [
            "sg-040ab77911d99ca3f"
        ]
    ],
    [
        "com.amazonaws.ap-south-1.ec2messages",
        [
            "sg-040ab77911d99ca3f"
        ]
    ]
]

---

**Tutor** (24 Nov 2026, 12:42 pm)

## Step 2 passed: all three endpoints now use `endpoint-sg`

Each interface endpoint lists only `sg-040ab77911d99ca3f`. The S3 gateway row is empty, which is correct because gateway endpoints have no security group.

### Next: check registration (Step 4)
Wait 2-5 minutes, then run:
```
aws ssm describe-instance-information --region ap-south-1
```
You want your instance `i-034eaffd299e9c196` with `PingStatus: Online`.

If it's still empty after 5 minutes, reboot once and wait 3 minutes:
```
aws ec2 reboot-instances --region ap-south-1 --instance-ids i-034eaffd299e9c196
```

### One thing to double-check if it stays empty
The earlier output showed the SG `endpoint-sg` allows 443 from `0.0.0.0/0`, so the inbound rule should already let the server in. If it still fails, check the server's own outbound rule:
```
aws ec2 describe-security-groups --region ap-south-1 --group-ids <ec2-sg-id> --query 'SecurityGroups[].IpPermissionsEgress'
```
It needs to allow outbound TCP 443 (the default allow-all is fine). Also check the role behind `lab3-ec2-ssm` has `AmazonSSMManagedInstanceCore`:
```
aws iam get-instance-profile --instance-profile-name lab3-ec2-ssm --query 'InstanceProfile.Roles[].RoleName'
aws iam list-attached-role-policies --role-name <role-name>
```

### After it shows Online: tighten the rule
Only then edit `endpoint-sg` inbound:
- Delete the `0.0.0.0/0` rule (description "web").
- Add HTTPS (TCP 443) with Source = the `ec2-sg` security group.

Re-run `describe-instance-information` afterward. It should stay Online, which proves the tighter rule is correct.

### Cost
The three interface endpoints are still billing (about $0.033/hr). Once the session tests are done, delete them.

### Self-check
- Why did the old endpoint SG (`sg-08cd...`) block the server even though DNS and endpoints were fine?
- Why do we tighten the rule only after seeing Online?

Paste the `describe-instance-information` output.

---

**You** (24 Nov 2026, 12:43 pm)

–
sgr-0bb3b048584520515
IPv4
HTTPS
TCP
443
0.0.0.0/0
web
 it is already added right

---

**Tutor** (24 Nov 2026, 12:43 pm)

## Yes, the rule exists, and it does allow the traffic

`sgr-0bb3b048584520515` is TCP 443 from `0.0.0.0/0` on `endpoint-sg`. For connectivity, that is enough: the server's 443 calls will be accepted now that the endpoints use this SG. So it is **not** what's blocking you.

### But it isn't the final rule
- `0.0.0.0/0` means "any source". Nothing outside can reach it (no internet route), but the brief and the auditors want least privilege.
- Final rule: HTTPS 443, source = the `ec2-sg` security group. Change it only **after** the instance shows Online, so you know what fixed what.

### Where we are
1. Endpoints use `endpoint-sg`: done.
2. Rule allows 443: done.
3. Next: wait 2-5 minutes, then run:
   ```
   aws ssm describe-instance-information --region ap-south-1
   ```
4. If still empty, reboot once (`aws ec2 reboot-instances --region ap-south-1 --instance-ids i-034eaffd299e9c196`), wait 3 minutes, and re-check.

### If it is still empty after the reboot
Two remaining suspects. Paste these outputs:
```
aws ec2 describe-instances --region ap-south-1 --instance-ids i-034eaffd299e9c196 --query 'Reservations[].Instances[].SecurityGroups'
aws iam get-instance-profile --instance-profile-name lab3-ec2-ssm --query 'InstanceProfile.Roles[].RoleName'
```
Then:
- Check that the server's SG has outbound 443 (default allow-all is fine).
- Check that the role has `AmazonSSMManagedInstanceCore` (`aws iam list-attached-role-policies --role-name <role>`).

Interesting detail: your `describe-security-groups` filter by tag only returned `endpoint-sg`. That means `ec2-sg` may be missing the `Project=aws-practice` tag. Add it, or your final cleanup check will miss it.

### Cost
The three interface endpoints are still billing (about $0.033/hr). If this drags on, delete them and recreate later.

### Self-check
- Why is the `0.0.0.0/0` rule harmless for connectivity but still a bad habit?
- What would the source be in the final rule?

Paste the `describe-instance-information` output after waiting.

---

**You** (24 Nov 2026, 12:46 pm)

"InstanceInformationList": []
}

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ec2 reboot-instances --region ap-south-1 --instance-ids i-034eaffd299e9c196
PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ssm describe-instance-information --region ap-south-1
>> 
{                                                                                                                                                                  
    "InstanceInformationList": [
        {
            "InstanceId": "i-034eaffd299e9c196",
            "PingStatus": "Online",
            "LastPingDateTime": "2026-11-24T12:44:35.496000+05:30",
            "AgentVersion": "3.3.5828.0",
            "IsLatestVersion": true,
            "PlatformType": "Linux",
            "PlatformName": "Amazon Linux",
            "PlatformVersion": "2023",
            "ResourceType": "EC2Instance",
            "IPAddress": "10.0.143.174",
            "ComputerName": "ip-10-0-143-174.ap-south-1.compute.internal",
            "SourceId": "i-034eaffd299e9c196",
            "SourceType": "AWS::EC2::Instance"
        }
    ]
}

You may not specify a referenced group id for an existing IPv4 CIDR rule.

while setting the http 445

---

**Tutor** (24 Nov 2026, 12:46 pm)

## The instance is Online

`PingStatus: Online`, agent `3.3.5828.0`, IP `10.0.143.174`. The server registered itself through the endpoints, so the SG swap plus the reboot fixed it. That ticks the `describe-instance-information` item.

## Your error: why it happened

`You may not specify a referenced group id for an existing IPv4 CIDR rule.`

- You edited the **existing** `0.0.0.0/0` rule and tried to change its source to a security group.
- AWS does not let one rule switch between a CIDR source and an SG source.
- Fix: **delete the old rule and add a new one**. Don't edit it in place.

Also check the port: it must be **443** (HTTPS), not 445. Port 445 is SMB, which SSM doesn't use.

## Fix, step by step

Console: EC2 → Security Groups → `endpoint-sg` → Inbound rules → Edit inbound rules:
1. **Delete** the `0.0.0.0/0` rule (`sgr-0bb3b048584520515`).
2. Click **Add rule**: Type HTTPS, Port **443**, Source type **Custom**, then pick the **`ec2-sg`** group from the dropdown (it starts with `sg-`).
3. Save.

Or CLI (get `ec2-sg`'s ID first from `describe-instances ... SecurityGroups`):
```
aws ec2 revoke-security-group-ingress --region ap-south-1 --group-id sg-040ab77911d99ca3f --security-group-rule-ids sgr-0bb3b048584520515
aws ec2 authorize-security-group-ingress --region ap-south-1 --group-id sg-040ab77911d99ca3f --protocol tcp --port 443 --source-group <ec2-sg-id>
```

Do the delete and add in one save, so the gap is seconds.

## Verify it still works
Re-run `describe-instance-information`. The instance should remain Online (the heartbeat can take a minute or two to show a failure if the rule is wrong). That proves the tighter rule is correct.

Also: add the tag `Project=aws-practice` to `ec2-sg` (your earlier tag filter only returned `endpoint-sg`), or your final cleanup check will miss it.

## Next checklist items
1. Security group inbound check on `ec2-sg` returns `[]`.
2. `aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1`, then inside it run `curl -m 5 https://www.google.com` (should time out).
3. Log bucket test over the S3 gateway endpoint (`aws s3 ls s3://<bucket>`).

## Cost
The three interface endpoints are billing (~$0.033/hr). Finish the session tests, then delete them if you stop for the day. Overnight would be about $0.80.

## Self-check
- Why can't a CIDR rule be edited into an SG-referenced rule?
- What does referencing `ec2-sg` as the source protect against that `0.0.0.0/0` doesn't?

**Exam relevance (SAP-C03):** SG-to-SG references give least privilege that follows instances, not IP ranges.

Paste the result of the Online recheck after the rule change.

---

**You** (24 Nov 2026, 12:47 pm)

done now what

---

**Tutor** (24 Nov 2026, 12:47 pm)

## Next: verify the tighter rule, then open your first session

### Step 1: confirm it stayed Online
```
aws ssm describe-instance-information --region ap-south-1 --query 'InstanceInformationList[].[InstanceId,PingStatus]'
```
You want `Online`. Also confirm the rule:
```
aws ec2 describe-security-groups --region ap-south-1 --group-ids sg-040ab77911d99ca3f --query 'SecurityGroups[].IpPermissions[].UserIdGroupPairs'
```
It should show your `ec2-sg` ID and no `0.0.0.0/0`. Existing connections can linger for a bit, so if you want a firm proof, reboot once and check that it comes back Online.

### Step 2: check `ec2-sg` has no inbound rules
```
aws ec2 describe-security-groups --region ap-south-1 --group-ids <ec2-sg-id> --query 'SecurityGroups[].IpPermissions'
```
It must print `[]`. Also tag `ec2-sg` with `Project=aws-practice` if you haven't.

### Step 3: open a shell (no SSH, no key)
```
aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
```
This needs the Session Manager plugin on your laptop. Inside the session, run:
```
whoami
curl -m 5 https://www.google.com
```
`curl` should time out. That proves there is no internet path while Session Manager still works. Type `exit` to leave.

### Step 4: S3 over the gateway endpoint
First check that the gateway endpoint is attached to your route table. The route table should now show a `pl-...` → `vpce-094a...` route.

Inside a session, run `aws s3 ls s3://<your-log-bucket>`. Note that `ls` needs **`s3:ListBucket`** on the bucket. The plan only gave the role `s3:PutObject`, so if you get AccessDenied, that is why. Add `s3:ListBucket` on the bucket ARN, or just test with `aws s3 cp` of a small file to the bucket.

### Step 5: session logging (the auditors' requirement)
Sessions aren't recorded until you turn it on:
- Console: Systems Manager → Session Manager → **Preferences** → Edit.
- Enable **S3 logging**, choose your log bucket, and add a prefix like `sessions/`.
- Encrypt logs: bucket default encryption (SSE-S3) is fine for now.

Then run another session, type a few commands, and `exit`. The transcript can take a minute or two to appear:
```
aws s3 ls s3://<your-log-bucket>/sessions/ --recursive
```
Also confirm the bucket has Block Public Access fully on and default encryption enabled.

### Step 6: resilience test
Terminate the instance, launch a replacement with the same role, subnet and `ec2-sg`, and time how long it takes to show Online. Expect about 2-5 minutes with no changes.

### Cost
The interface endpoints are billing at about $0.033/hr. Once Steps 3-6 are done, delete them straight away. Don't leave them overnight (about $0.80). Then work through the clean-delete checks.

### Self-check
- Why did the `curl` to Google fail while the session itself works?
- Who writes the session transcript to S3: your laptop, or the server? What does that mean for the role's permissions?

**Exam relevance (SAP-C03):** Session Manager gives auditable access with no inbound ports, and the logs go to S3 or CloudWatch Logs.

Paste the results of Steps 2 and 3 when you have them.

---

**You** (24 Nov 2026, 12:50 pm)

PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
>> 

aws: [ERROR]: SessionManagerPlugin is not found. Please refer to SessionManager Documentation here: http://docs.aws.amazon.com/console/systems-manager/session-manager-plugin-not-found
PS C:\Users\asgha\Desktop\AWS\Customer Cases\L3 Private SSH>

---

**Tutor** (24 Nov 2026, 12:50 pm)

## Cause: the Session Manager plugin isn't installed on your laptop

`aws ssm start-session` needs a small local plugin to open the shell. The AWS CLI alone can't do it. Your server side is fine (it's Online). This is a laptop-only fix, and it costs $0.

### Quickest option while the meter runs: use the Console
The three interface endpoints are billing (~$0.033/hr), so you can test now without installing anything:
- Systems Manager → **Session Manager** → **Start session** → select `i-034eaffd299e9c196` → **Start session**.
- Or EC2 → Instances → select it → **Connect** → **Session Manager** tab → Connect.

Run `whoami` and `curl -m 5 https://www.google.com` (should time out). The checklist wants the CLI version eventually, so do the install below too.

### Install the plugin on Windows
1. Download the installer: https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe
2. Run it (admin rights may be needed) and finish the wizard.
3. **Close and reopen PowerShell.** The PATH only updates in new windows.
4. Verify:
   ```
   session-manager-plugin
   ```
   It should print: `The Session Manager plugin was installed successfully...`
5. Retry:
   ```
   aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
   ```

Alternatively, `winget` may have it, but the official installer above is the safest path.

### If it still says "not found"
- You are in the old PowerShell window. Open a new one.
- Check the folder `C:\Program Files\Amazon\SessionManagerPlugin\bin\` exists and is on PATH.

### Docs
https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

### Keep an eye on time
Do these in order, then delete the interface endpoints: shell test, S3 test, session logging, replacement test. A 1-2 hour session is roughly $0.07 for endpoints, well inside the USD 1 cap.

### Self-check
- Why does the Console work without the plugin but the CLI doesn't?
- Which side of the connection needs the plugin: the server or your laptop?

**Exam relevance (SAP-C03):** the plugin is part of the client-side requirement for CLI sessions. The server needs only the agent, the role, and the endpoints.

Tell me what `whoami` and the `curl` timeout show once you're in.

---

**You** (24 Nov 2026, 12:55 pm)

aws <command> <subcommand> help

PS C:\Users\asgha\Desktop\AWS> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
>> 

aws: [ERROR]: SessionManagerPlugin is not found. Please refer to SessionManager Documentation here: http://docs.aws.amazon.com/console/systems-manager/session-manager-plugin-not-found
PS C:\Users\asgha\Desktop\AWS>  I just installed it

---

**Tutor** (24 Nov 2026, 12:55 pm)

## Almost certainly a PATH issue: the plugin is installed, but this window can't find it

Windows only reads the updated PATH when a program starts. Your PowerShell window (or the editor terminal it runs in) was opened before the install, so it still has the old PATH.

### Fix 1: fully restart the terminal
- Close **all** PowerShell windows. If you use VS Code or Windows Terminal, close the whole app, not just the tab.
- Open a fresh PowerShell and run:
  ```
  session-manager-plugin
  ```
  Expected: `The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.`
- Then retry:
  ```
  aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
  ```

### Fix 2: if it still says "not found"
Check that the file exists:
```
Test-Path "C:\Program Files\Amazon\SessionManagerPlugin\bin\session-manager-plugin.exe"
```
- **True**: it's installed but not on PATH. Add it for this window only:
  ```
  $env:Path += ";C:\Program Files\Amazon\SessionManagerPlugin\bin"
  ```
  Then retry `aws ssm start-session`. To make it permanent, add that folder in Windows Settings → Environment Variables → Path.
- **False**: the installer didn't finish. Re-run `SessionManagerPluginSetup.exe` as administrator.

### Meanwhile
The Console works with no plugin: EC2 → Instances → select the server → **Connect** → **Session Manager** tab. You can run the `whoami` and `curl -m 5 https://www.google.com` tests there if you want to keep moving.

### Cost
The three interface endpoints are still billing (~$0.033/hr). Don't let plugin troubleshooting run long. If you take a break, delete them.

### Self-check
- Why does a newly installed program not show up in an already-open terminal?
- Which two checks prove the plugin is installed: the command output or the file path?

Tell me what `session-manager-plugin` prints in the new window.

---

**You** (24 Nov 2026, 12:56 pm)

works actually with $env thing

---

**Tutor** (24 Nov 2026, 12:56 pm)

## Nice: that confirms the plugin is installed, it was only a PATH problem

The `$env:Path` line fixed it for **this window only**. A new PowerShell window will fail again unless you add the folder permanently:
- Windows Search → "Edit environment variables for your account" → **Path** → Edit → New → `C:\Program Files\Amazon\SessionManagerPlugin\bin` → OK.
- Open a new PowerShell and run `session-manager-plugin` to confirm.

(Not urgent. You can do it after the tests.)

### Now run the session tests
Inside your open session:
```
whoami
curl -m 5 https://www.google.com
```
- `whoami` should print `ssm-user`. That is the account Session Manager uses, with no key involved.
- `curl` should time out after 5 seconds. That is your proof of no internet path. A timeout here is a **pass**.

Then the S3 test, which uses the gateway endpoint:
```
aws s3 ls s3://<your-log-bucket>
```
If you get AccessDenied, the role has only `s3:PutObject` and `ls` needs `s3:ListBucket` on the bucket ARN. Add it, or test with a small `aws s3 cp` upload instead. If it hangs, check that the gateway endpoint is attached to your route table.

Type `exit` to leave the session.

### Then, in order
1. Turn on session logging (Systems Manager → Session Manager → Preferences → S3 logging, prefix `sessions/`). Run another short session, type a few commands, exit, and check `aws s3 ls s3://<bucket>/sessions/ --recursive`.
2. Confirm `ec2-sg` shows `[]` for inbound rules and has the `Project=aws-practice` tag.
3. Terminate and replace the instance (same role, subnet, SG) and time how long it takes to show Online.
4. Delete the three interface endpoints, then run the clean-delete checks.

### Cost
The interface endpoints are billing (~$0.033/hr). Once step 3 is done, delete them straight away. Overnight would be about $0.80.

### Self-check
- Why does a `curl` timeout count as a pass here?
- Why does the transcript logging need the instance role to have S3 write permission, and not your laptop?

**Exam relevance (SAP-C03):** Session Manager gives shell access with no inbound ports or keys, and IAM plus session logs give you the audit trail.

Paste what `curl` and the S3 command print.

---

**You** (24 Nov 2026, 1:04 pm)

sh-5.2$ aws s3 ls s3://<bucket>/sessions/ --recursive
sh: bucket: No such file or directory
sh-5.2$ aws s3 ls s3://lab3-cloudtrail-bucket-akash/sessions/ --recursive
sh-5.2$

---

**Tutor** (24 Nov 2026, 1:04 pm)

## Two things happened here

### 1. The first error was just a typo
`<bucket>` was a placeholder, not a real name. In `sh`, `<bucket>` means "read input from a file called bucket", hence `No such file or directory`. Always replace the `<...>` parts completely.

### 2. The second command worked, and empty output is a valid result
No error and no output means:
- The S3 call went through the **gateway endpoint**, the role has the needed permission, and the bucket is reachable.
- There are simply no objects under `sessions/` yet. Nothing has been written, because session logging isn't switched on (or this session started before you enabled it).

Check the bucket root too, to confirm the connection works:
```
aws s3 ls s3://lab3-cloudtrail-bucket-akash/
```

### A bucket name to reconsider
`lab3-cloudtrail-bucket-akash` sounds like the **CloudTrail** bucket. I suggested keeping CloudTrail and session logs in separate buckets. Session logs should go to their own bucket with Block Public Access on, default encryption on, and a 365-day lifecycle rule. If this is the CloudTrail bucket, create a separate session-log bucket now (free for a few KB).

### Turn on session logging
Console: Systems Manager → Session Manager → **Preferences** → Edit:
- Enable **S3 logging**, choose the session-log bucket, prefix `sessions/`.
- Save.

The instance role needs `s3:PutObject` on `arn:aws:s3:::<session-log-bucket>/sessions/*`. If you also want the encrypted-bucket option checked, the agent calls `s3:GetEncryptionConfiguration` on the bucket, so add that as well.

### Then test
1. `exit` your current session and start a **new** one (settings apply to new sessions only).
2. Run a few commands, such as `whoami`, `ls /`, `uptime`, then `exit`.
3. Wait 1-2 minutes, then from your laptop (not inside the session):
```
aws s3 ls s3://<your-session-log-bucket>/sessions/ --recursive
```
You should see an object named with the session ID. Download it with `aws s3 cp` and read it: that is the auditors' record of what was typed.

### Did you finish these earlier checks?
- `curl -m 5 https://www.google.com` timed out?
- `ec2-sg` inbound returns `[]` and carries the `Project=aws-practice` tag?

### Cost
The interface endpoints are still billing (~$0.033/hr). After the log test and the replacement test, delete them. Overnight would be about $0.80.

### Self-check
- Why does `sh` say "No such file or directory" for `<bucket>`?
- Who writes the transcript to S3, and which identity needs the permission?

**Exam relevance (SAP-C03):** Session Manager logging to S3 or CloudWatch Logs, with CloudTrail recording who started the session, is the standard audit answer.

Paste the output of the laptop-side `aws s3 ls` after your new session.

---

**You** (24 Nov 2026, 1:05 pm)

I already trunned on

---

**Tutor** (24 Nov 2026, 1:05 pm)

## Good. So why is `sessions/` empty? Let's check three likely causes

You turned logging on, but the listing was empty. Most likely one of these:

### 1. The session started before you saved the setting
Preferences apply to **new** sessions only. Your current shell was opened earlier. Do this:
- Type `exit`.
- Start a new session, run `whoami`, `ls /`, `uptime`, then `exit`.
- Wait 1-2 minutes. **Logs are uploaded when the session ends**, not while it runs.

### 2. You listed from inside the server
Run the check from your **laptop**, with your admin credentials:
```
aws s3 ls s3://lab3-cloudtrail-bucket-akash/ --recursive
```
Drop the `sessions/` prefix for now. If the logging prefix was left blank or typed differently, files land elsewhere.

### 3. The instance role can't write there
The agent on the server writes the transcript using the **instance role**. Check:
- The `s3:PutObject` policy covers the **same bucket** you chose in Preferences, and the prefix (`.../sessions/*` or the whole bucket).
- Add `s3:GetEncryptionConfiguration` on the bucket ARN too. The agent checks this and can fail without it.

### Check the preferences saved
```
aws ssm get-document --region ap-south-1 --name SSM-SessionManagerRunShell --query Content --output text
```
Look for `"s3BucketName"` with your bucket name and `"s3KeyPrefix"`. If the document doesn't exist, the preferences were never saved.

### Find the error if it still fails
On the server, in a session:
```
sudo tail -n 30 /var/log/amazon/ssm/amazon-ssm-agent.log
```
Look for `AccessDenied` or S3 errors.

### Reminder on the bucket
That bucket name sounds like your **CloudTrail** bucket. If it is, create a separate session-log bucket (Block Public Access on, default encryption on, 365-day expiry) and point both the preference and the role policy at it. CloudTrail's bucket policy is specific, and mixing them gets messy.

### Cost
The three interface endpoints are still billing (~$0.033/hr). Don't leave them running overnight (about $0.80).

### Self-check
- Why are transcripts only visible after a session ends?
- Which identity needs the S3 permission: you, or the instance role?

**Exam relevance (SAP-C03):** Session logs are written by the agent using the instance role. CloudTrail shows who started the session, and the S3 transcript shows what they typed.

Paste the output of the `get-document` command and the laptop-side `aws s3 ls`.

---

**You** (24 Nov 2026, 1:06 pm)

sh-5.2$ aws s3 ls s3://<bucket>/sessions/ --recursive
sh: bucket: No such file or directory
sh-5.2$ aws s3 ls s3://lab3-cloudtrail-bucket-akash/sessions/ --recursive
sh-5.2$ aws s3 ls s3://lab3-cloudtrail-bucket-akash/

sh-5.2$ 
sh-5.2$ aws s3 ls s3://lab3-cloudtrail-bucket-akash/ --recursive

sh-5.2$ 
sh-5.2$ aws ssm get-document --region ap-south-1 --name SSM-SessionManagerRunShell --query Content --output text

{"schemaVersion":"1.0","description":"Document to hold regional settings for Session Manager","sessionType":"Standard_Stream","inputs":{"s3BucketName":"lab3-cloudtrail-bucket-akash","s3KeyPrefix":"/sessions","s3EncryptionEnabled":true,"cloudWatchLogGroupName":"","cloudWatchEncryptionEnabled":true,"cloudWatchStreamingEnabled":true,"idleSessionTimeout":"20","maxSessionDuration":"","kmsKeyId":"","runAsEnabled":false,"runAsDefaultUser":"","shellProfile":{"windows":"","linux":""}}}
sh-5.2$ 
sh-5.2$ sudo tail -n 30 /var/log/amazon/ssm/amazon-ssm-agent.log


2026-11-24 07:26:43.2551 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Setting up datachannel for session: akash-extl58ibgz9a6u7iprq7eqotay, requestId: f71ddd45-b093-4f4e-89ea-b28f090ffc30, clientId: 
2026-11-24 07:26:43.2922 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Opening websocket connection to: wss://ssmmessages.ap-south-1.amazonaws.com/v1/data-channel/akash-extl58ibgz9a6u7iprq7eqotay?role=publish_subscribe
2026-11-24 07:26:43.3065 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Successfully opened websocket connection to: 10.0.134.183:443
2026-11-24 07:26:43.3066 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Starting websocket pinger
2026-11-24 07:26:43.3067 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Starting websocket listener
2026-11-24 07:26:43.3067 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Skipping handshake.
2026-11-24 07:26:43.3069 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Starting command executor
2026-11-24 07:26:43.3112 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] ssm-user already exists.
2026-11-24 07:26:43.3195 INFO [ssm-session-worker] [akash-extl58ibgz9a6u7iprq7eqotay] [DataBackend] [pluginName=Standard_Stream] Plugin Standard_Stream started
2026-11-24 07:27:33.2815 INFO [CredentialRefresher] Next credential rotation will be in 16.999592426316667 minutes
2026-11-24 07:28:33.2515 INFO [CredentialRefresher] Next credential rotation will be in 16.00009239705 minutes
2026-11-24 07:29:33.2815 INFO [CredentialRefresher] Next credential rotation will be in 14.999592449116667 minutes
2026-11-24 07:29:34.5558 INFO [ssm-agent-worker] [LongRunningPluginsManager] There are no long running plugins currently getting executed - skipping their healthcheck
2026-11-24 07:29:53.5555 INFO [ssm-agent-worker] [HealthCheck] HealthCheck reporting agent health.
2026-11-24 07:29:53.5555 INFO [ssm-agent-worker] [HealthCheck] Agent does not have an explicit provider.
2026-11-24 07:29:53.5579 INFO [EC2Identity] Creating IPR provider with IMDS client
2026-11-24 07:29:53.5585 INFO [ECSIdentity] Agent not taking ECS identity: Could not fetch metadata endpoint
2026-11-24 07:30:33.2674 INFO [CredentialRefresher] Next credential rotation will be in 13.9998266346 minutes
2026-11-24 07:31:33.2804 INFO [CredentialRefresher] Next credential rotation will be in 12.999611056316667 minutes
2026-11-24 07:32:33.2790 INFO [CredentialRefresher] Next credential rotation will be in 11.999633075183333 minutes
2026-11-24 07:33:33.2449 INFO [CredentialRefresher] Next credential rotation will be in 11.000201900716666 minutes
2026-11-24 07:34:33.2771 INFO [CredentialRefresher] Next credential rotation will be in 9.999665491666667 minutes
2026-11-24 07:34:34.5563 INFO [ssm-agent-worker] [MessageService] [MessageHandler] started idempotency deletion thread
2026-11-24 07:34:34.5563 INFO [ssm-agent-worker] [MessageService] [MessageHandler] ended idempotency deletion thread
2026-11-24 07:34:53.5556 INFO [ssm-agent-worker] [HealthCheck] HealthCheck reporting agent health.
2026-11-24 07:34:53.5556 INFO [ssm-agent-worker] [HealthCheck] Agent does not have an explicit provider.
2026-11-24 07:34:53.5582 INFO [EC2Identity] Creating IPR provider with IMDS client
2026-11-24 07:34:53.5588 INFO [ECSIdentity] Agent not taking ECS identity: Could not fetch metadata endpoint
2026-11-24 07:35:01.2666 INFO [ssm-agent-worker] [MessageService] [Association] Schedule manager refreshed with 0 associations, 0 new associations associated
2026-11-24 07:35:33.2715 INFO [CredentialRefresher] Next credential rotation will be in 8.999759143316666 minutes
sh-5.2$

---

**Tutor** (24 Nov 2026, 1:06 pm)

## What your output tells us

### 1. The preferences saved correctly
`get-document` shows `s3BucketName` set to your bucket, `s3EncryptionEnabled: true`, and `s3KeyPrefix` set to `"/sessions"`.

### 2. The agent log is from a session that is still open
The log shows session `akash-extl58ibgz9a6u7iprq7eqotay` starting at 07:26 and no "session ended" or upload line after it. The transcript is uploaded when the session **terminates**, so there is nothing to find yet. That is the main reason for the empty listing.

Also, the log was started after you saved preferences (the session worker would have picked them up at start), so the setting itself is probably fine.

### 3. Fix the prefix anyway
`"/sessions"` has a leading slash. In S3 that can create an odd key starting with `/` (shown as an empty-named folder). Set it to `sessions` with no slashes:
- Systems Manager → Session Manager → Preferences → Edit → S3 key prefix = `sessions` → Save.

### Do this now
1. Type `exit` in the session. Then close that session fully.
2. Start a **new** session, run `whoami`, `ls /`, `uptime`, then `exit`.
3. Wait 1-2 minutes. From your **laptop** (not the server), list the whole bucket:
   ```
   aws s3 ls s3://lab3-cloudtrail-bucket-akash/ --recursive
   ```
4. If still empty, search the agent log for the upload error:
   ```
   sudo grep -iE "s3|AccessDenied|upload" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 20
   ```
   Also check `/var/log/amazon/ssm/ssm-session-worker/`, where the per-session logs are written.

### The likely culprit if it is still empty: the role policy
- The instance role needs `s3:PutObject` on `arn:aws:s3:::lab3-cloudtrail-bucket-akash/sessions/*` (or the whole bucket).
- Add `s3:GetEncryptionConfiguration` on `arn:aws:s3:::lab3-cloudtrail-bucket-akash`. Because `s3EncryptionEnabled` is true, the agent checks the bucket's encryption. If the bucket has no default encryption set, the upload is refused, so confirm default encryption (SSE-S3) is on.
- Ignore the `cloudWatch...` fields. Logging to CloudWatch is off (empty log group).

### Bucket advice (repeat)
`lab3-cloudtrail-bucket-akash` is named like your CloudTrail bucket. A separate session-log bucket (Block Public Access on, default encryption on, 365-day expiry) is cleaner. A CloudTrail bucket policy is specific to CloudTrail, and mixing them complicates things. Creating one costs ~$0.

### Cost
Interface endpoints are still billing at ~$0.033/hr. Finish the log test and the replacement test, then delete them. Overnight would cost about $0.80.

### Self-check
- Why is there no transcript while the session is still open?
- Why can a leading `/` in a key prefix cause confusion?

**Exam relevance (SAP-C03):** the agent writes the transcript with the instance role's permissions, and with S3 encryption enforced it needs the bucket's encryption config to be readable.

Paste the laptop-side `aws s3 ls --recursive` after you exit and start a new session.

---

**You** (24 Nov 2026, 1:07 pm)

2026-11-24 07:34:53.5556 INFO [ssm-agent-worker] [HealthCheck] Agent does not have an explicit provider.
2026-11-24 07:34:53.5582 INFO [EC2Identity] Creating IPR provider with IMDS client
2026-11-24 07:34:53.5588 INFO [ECSIdentity] Agent not taking ECS identity: Could not fetch metadata endpoint
2026-11-24 07:35:01.2666 INFO [ssm-agent-worker] [MessageService] [Association] Schedule manager refreshed with 0 associations, 0 new associations associated
2026-11-24 07:35:33.2715 INFO [CredentialRefresher] Next credential rotation will be in 8.999759143316666 minutes
sh-5.2$ exit
exit


Exiting session with sessionId: akash-extl58ibgz9a6u7iprq7eqotay.

PS C:\Users\asgha\Desktop\AWS> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1

Starting session with SessionId: akash-kylxl3ogcn5o666cf394jtetaa

i t is stuck

---

**Tutor** (24 Nov 2026, 1:07 pm)

## "Stuck" after "Starting session" is usually normal for a few seconds, so wait first

### 1. Give it 10-20 seconds and press Enter
The shell prompt (`sh-5.2$`) often doesn't appear until you press **Enter** once. The agent is starting a shell and opening the websocket via the `ssmmessages` endpoint.

### 2. If nothing after ~30 seconds
Open a **new** PowerShell window (add the plugin to PATH again with the `$env:Path` line) and check the session state:
```
aws ssm describe-sessions --state Active --region ap-south-1 --query 'Sessions[].[SessionId,Status,Target]'
```
Then cancel the stuck one from the same window:
```
aws ssm terminate-session --session-id akash-kylxl3ogcn5o666cf394jtetaa --region ap-south-1
```
Press `Ctrl+C` in the stuck window if it doesn't close, then start a fresh session.

### 3. Why it might hang now (and it worked before)
Session logging is now being enforced. With `s3EncryptionEnabled: true`, the agent checks the log bucket before opening the shell. If it can't, the session can hang or close straight away. Likely causes:
- The instance role is missing `s3:GetEncryptionConfiguration` on the bucket ARN (`arn:aws:s3:::lab3-cloudtrail-bucket-akash`).
- The bucket has no default encryption enabled.
- The role's `s3:PutObject` doesn't cover the bucket or prefix.

Quick fix to test the theory: add `s3:GetEncryptionConfiguration` and `s3:PutObject` for this bucket to the role's custom policy, confirm the bucket has default encryption (SSE-S3) on, then start a new session.

### 4. Find the actual error
If you can open a session via the Console (EC2 → Connect → Session Manager), run:
```
sudo grep -iE "s3|AccessDenied|encrypt|error" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 20
ls /var/log/amazon/ssm/ssm-session-worker/
```
If no session opens at all, check the Console for the error banner, or the agent log through a working method, and paste what you see.

### 5. Last resort, to keep the cost down
If you can't fix it in about 20 minutes, turn off S3 logging temporarily (Preferences → uncheck S3 logging) to prove the session itself works, then re-enable it after fixing the policy. The interface endpoints are billing (~$0.033/hr); delete them if you stop for the day.

### Self-check
- Why does a leaving-out-`GetEncryptionConfiguration` permission show up as a hang rather than a clear error?
- Why does `s3EncryptionEnabled: true` require the bucket's default encryption to be on?

**Exam relevance (SAP-C03):** if you enforce encrypted session logs, the instance role needs both S3 write access and the ability to read the bucket's encryption configuration.

Tell me whether pressing Enter showed a prompt, and paste the `describe-sessions` output if not.

---

**You** (24 Nov 2026, 1:11 pm)

nothing still stuck

---

**Tutor** (24 Nov 2026, 1:11 pm)

## Let's stop waiting and diagnose from the outside

You've waited long enough. Treat it as a real fault. Most likely it's the log-bucket check I described last time, but we confirm with evidence rather than guessing.

### Step 1: kill the stuck session (new PowerShell window)
Re-add the plugin path in the new window first:
```
$env:Path += ";C:\Program Files\Amazon\SessionManagerPlugin\bin"
aws ssm describe-sessions --state Active --region ap-south-1 --query 'Sessions[].[SessionId,Status,Target]'
aws ssm terminate-session --session-id akash-kylxl3ogcn5o666cf394jtetaa --region ap-south-1
```
Then `Ctrl+C` in the stuck window.

### Step 2: test whether sessions work at all
Open a shell from the **Console** (EC2 → Instances → Connect → Session Manager). The result tells us which side is broken:
- **Console works, CLI hangs**: a laptop-side problem (plugin or terminal). Try a fresh PowerShell window.
- **Console also hangs or closes**: the agent can't finish setup, so it's the logging check or the role.

### Step 3: check the role's S3 permissions
```
aws iam list-attached-role-policies --role-name <role-name>
aws iam list-role-policies --role-name <role-name>
```
Then open the custom policy. For the log bucket it should allow:
- `s3:PutObject` on `arn:aws:s3:::lab3-cloudtrail-bucket-akash/sessions/*`
- `s3:GetEncryptionConfiguration` on `arn:aws:s3:::lab3-cloudtrail-bucket-akash`

Also check the bucket itself: Console → S3 → bucket → Properties → **Default encryption** must be on.

### Step 4: fix the prefix
Your saved prefix is `/sessions` with a leading slash. Change it to `sessions` in Session Manager → Preferences.

### Step 5: isolate the cause (quickest test)
Temporarily untick **S3 logging** in Preferences and save, then start a new session.
- Session opens: the logging setup is the cause. Fix the policy and encryption, re-enable logging.
- Still hangs: it's not logging. Check the agent log (`sudo tail -n 50 /var/log/amazon/ssm/amazon-ssm-agent.log`) from a Console session, or reboot the instance and wait 3 minutes for it to show Online again.

Don't leave logging off. The auditors require it, so this is only a test.

### Cost
The three interface endpoints are billing about $0.033/hr. If this takes more than 20-30 minutes, delete them and recreate later (a few cents). Overnight would be about $0.80.

### Self-check
- What does a working Console session but hanging CLI session tell you?
- Why do we turn logging off only as a test, not as the fix?

**Exam relevance (SAP-C03):** when a mandatory logging requirement fails, sessions can fail closed. Diagnose by isolating one variable at a time.

Tell me what happens in the Console session, and whether Step 5 opens a session.

---

**You** (24 Nov 2026, 1:11 pm)

PS C:\Users\asgha\Desktop\AWS> aws ssm describe-sessions --state Active --region ap-south-1 --query 'Sessions[].[SessionId,Status,Target]'
[]                                                                                                                                                           

PS C:\Users\asgha\Desktop\AWS> aws ssm terminate-session --session-id akash-kylxl3ogcn5o666cf394jtetaa --region ap-south-1
>> 

aws: [ERROR]: An error occurred (ValidationException) when calling the TerminateSession operation: Session is not in a valid state
PS C:\Users\asgha\Desktop\AWS> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1                                     
   
Starting session with SessionId: akash-y75vi7vj4joz36xcelz9brfaxi

---

**Tutor** (24 Nov 2026, 1:11 pm)

## Useful clue: the stuck session isn't active on the AWS side

`describe-sessions --state Active` returned `[]`, and `terminate-session` said "not in a valid state". So the old session already ended or never fully opened. Your new session `akash-y75vi7vj4joz36xcelz9brfaxi` printed "Starting session" and may now be in the same state.

"Starting session with SessionId" only means the service created the session record. The shell hasn't necessarily opened yet. Whether it hangs now decides the next step.

### Step 1: press Enter in this window
Wait about 15 seconds and press **Enter** once. If `sh-5.2$` appears, it's working.

### Step 2: if still blank, check from a second window
```
aws ssm describe-sessions --state History --region ap-south-1 --query 'Sessions[0].[SessionId,Status,Target,Details]'
aws ssm describe-sessions --state Active --region ap-south-1 --query 'Sessions[].[SessionId,Status]'
```
- **Active and shows the session**: the AWS side is fine, so suspect a laptop-side terminal problem. Close the window and try a fresh PowerShell, or run it in Windows Terminal.
- **Empty or Failed**: the agent isn't completing setup, so go to Step 3.

### Step 3: isolate the logging variable (fastest test)
In the Console: Systems Manager → Session Manager → Preferences → Edit:
- Untick **S3 logging**, save, and start a new session.
- Opens: logging is the cause. Fix the role policy (`s3:PutObject` on `.../sessions/*`, `s3:GetEncryptionConfiguration` on the bucket), set the prefix to `sessions` with no leading slash, confirm the bucket has default encryption on, then re-enable.
- Still hangs: logging is not the cause. Try a Console session (EC2 → Connect → Session Manager) and reboot the instance if needed.

Logging off is a test only. The auditors require it back on.

### Step 4: read the agent's own error
If a Console session opens, run:
```
sudo ls -t /var/log/amazon/ssm/ssm-session-worker/ | head
sudo grep -iE "error|denied|s3|encrypt" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 20
```
Paste what you see.

### Cost
The three interface endpoints are billing about $0.033/hr. You're probably around 2 hours in, so roughly $0.07 so far, well inside the USD 1 cap. If this isn't fixed in about 20 more minutes, delete the endpoints (keep the free S3 gateway one) and continue later. Overnight would be about $0.80.

### Self-check
- What does "Starting session with SessionId" actually confirm, and what doesn't it confirm?
- Why is testing with logging off a diagnosis step rather than a fix?

Tell me whether Enter brought up a prompt, and paste the Step 2 output if not.

---

**You** (24 Nov 2026, 1:11 pm)

PS C:\Users\asgha\Desktop\AWS> aws ssm describe-sessions --state History --region ap-south-1 --query 'Sessions[0].[SessionId,Status,Target,Details]'
>> aws ssm describe-sessions --state Active --region ap-south-1 --query 'Sessions[].[SessionId,Status]'
>> 
[                                                                                                                                                            
    "akash-y75vi7vj4joz36xcelz9brfaxi",
    "Terminated",
    "i-034eaffd299e9c196",
    null
]

[]                                                                                                                                                           

PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:12 pm)

## What this output tells us

- The newest session `akash-y75vi7vj4joz36xcelz9brfaxi` is **Terminated**, with no active sessions. So it did not hang. It opened and then closed, or it was closed right after starting.
- `Details` is null, so AWS gives no reason. The reason lives on the instance (agent and session-worker logs).
- Why it closes: with S3 logging enabled, the agent checks the log bucket at session start. If it can't, it ends the session. That fits "worked before logging, fails after".

### Step 1: reach the instance another way
Try the Console: EC2 → Instances → select the server → **Connect** → **Session Manager** tab.
- If it opens, read the logs (Step 3).
- If it also closes, go to Step 2 straight away.

### Step 2: switch S3 logging off temporarily (diagnosis only)
Systems Manager → Session Manager → Preferences → Edit → untick **S3 logging** → Save. Start a new session from the CLI.
- Opens and stays open: logging is the cause. Move on to the fix.
- Still closes: logging is not the cause. Reboot the instance, wait 3 minutes, and recheck `describe-instance-information`.

### Step 3: read the real error (from a working session)
```
sudo ls -t /var/log/amazon/ssm/ssm-session-worker/ | head -3
sudo grep -iE "error|denied|s3|encrypt" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 20
```
Paste what you get.

### The fix, once logging is the confirmed cause
1. **Prefix:** set `S3 key prefix` to `sessions` (no leading slash).
2. **Role policy:** the instance role needs
   - `s3:PutObject` on `arn:aws:s3:::lab3-cloudtrail-bucket-akash/sessions/*`
   - `s3:GetEncryptionConfiguration` on `arn:aws:s3:::lab3-cloudtrail-bucket-akash`
3. **Bucket:** default encryption (SSE-S3) must be on. The setting `s3EncryptionEnabled: true` requires it.
4. **Better:** create a **separate session-log bucket** (Block Public Access on, default encryption on, 365-day expiry) instead of using the CloudTrail bucket, and point the preferences and the policy at it. Cost: about $0.

Then re-enable logging, start a new session, run a few commands, `exit`, and list the bucket from your laptop.

### Cost
The interface endpoints are billing (~$0.033/hr). You are probably 2+ hours in, which is around $0.07, well inside the USD 1 cap. If this isn't solved in about 20 minutes, delete the three interface endpoints (keep the free S3 gateway one), and recreate them later for a few cents. Never leave them overnight (~$0.80).

### Self-check
- What does a **Terminated** session with null `Details` tell you about where to look next?
- Why does enabling a mandatory log setting make sessions fail closed rather than open without logging?

**Exam relevance (SAP-C03):** session logging to S3 needs both the instance role's write permission and a bucket that meets the encryption setting. Missing either can stop sessions.

Tell me which of the Console session or the logging-off test opened a shell, and paste the log lines if you reach Step 3.

---

**You** (24 Nov 2026, 1:12 pm)

PS C:\Users\asgha\Desktop\AWS> aws ssm describe-sessions --state Active --region ap-south-1 --query 'Sessions[].[SessionId,Status,Target]'
[]                                                                                                                                                           

PS C:\Users\asgha\Desktop\AWS> aws ssm terminate-session --session-id akash-kylxl3ogcn5o666cf394jtetaa --region ap-south-1
>> 

aws: [ERROR]: An error occurred (ValidationException) when calling the TerminateSession operation: Session is not in a valid state
PS C:\Users\asgha\Desktop\AWS> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1                                     
   
Starting session with SessionId: akash-y75vi7vj4joz36xcelz9brfaxi

aws: [ERROR]: Command '['session-manager-plugin', 'AWS_SSM_START_SESSION_RESPONSE', 'ap-south-1', 'StartSession', '', '{"Target": "i-034eaffd299e9c196"}', 'https://ssm.ap-south-1.amazonaws.com']' returned non-zero exit status 3221225786.

---

**Tutor** (24 Nov 2026, 1:12 pm)

## That error explains the "stuck" sessions: it is the plugin on your laptop, not AWS

`returned non-zero exit status 3221225786` is Windows code `0xC000013A` (`STATUS_CONTROL_C_EXIT`). It means the plugin process was **interrupted**, most likely by your `Ctrl+C` in the stuck window. So that error is the plugin being killed, not a new fault.

Together with the earlier output, it means:
- AWS created the session and the instance side is fine (the agent log showed the websocket opening through the `ssmmessages` endpoint).
- The session ended as **Terminated** because the local plugin was killed or lost its terminal. It did not fail closed because of logging.
- I was too quick to blame S3 logging. Treat it as unproven until a session actually opens.

### Why the shell showed nothing
Most likely the terminal. The plugin needs a real console to pass keystrokes. Likely culprits are an embedded or editor terminal, or the `$env:Path` session you patched by hand.

### Do this, in order
1. Close every terminal. Open a **plain Windows PowerShell** (Start menu), not an editor terminal.
2. Add the plugin path (the permanent fix is in Environment Variables, as before):
   ```
   $env:Path += ";C:\Program Files\Amazon\SessionManagerPlugin\bin"
   session-manager-plugin
   ```
3. Start a session and **press Enter once**:
   ```
   aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
   ```
4. Don't press `Ctrl+C` inside the session. Type `exit` to leave.

### Cross-check with the Console
EC2 → Instances → Connect → **Session Manager** tab. If this opens a shell, the AWS side is fully healthy and only the laptop terminal is the problem.

### Only if both fail
Then test the logging theory: untick S3 logging in Preferences, retry, and fix the policy (`s3:PutObject` on `.../sessions/*`, `s3:GetEncryptionConfiguration` on the bucket). Also set the prefix to `sessions` with no leading slash.

### Bucket reminder
`lab3-cloudtrail-bucket-akash` is your CloudTrail bucket. Use a separate session-log bucket (Block Public Access on, default encryption on, 365-day expiry). Cost is about $0.

### Cost
The three interface endpoints are still billing (~$0.033/hr). If this runs past about 20 more minutes, delete them (keep the free S3 gateway endpoint) and recreate later for a few cents. Overnight would be about $0.80, and the total is still well under the USD 1 cap.

### Self-check
- Why does `0xC000013A` point at a local interrupt, not an AWS error?
- What did the agent log lines (websocket opened to port 443) already prove about the server side?

**Exam relevance (SAP-C03):** Session Manager has a client side (CLI and plugin), a service side, and an agent side. Isolate which one fails before changing IAM or networking.

Tell me whether the plain PowerShell or the Console session opened a shell.

---

**You** (24 Nov 2026, 1:14 pm)

Session terminated akash-rp8hccatanojp397a7bgft5ncy

Your session has been terminated.

---

**Tutor** (24 Nov 2026, 1:14 pm)

## "Session terminated" in the Console is a real clue, and it's different from the plugin error

The session was created and then closed straight away. The earlier agent log shows a clean websocket through `ssmmessages`, so the network and endpoints are fine. This points at the **agent refusing to start the shell**. S3 logging is now the prime suspect. It was unproven before, but this takes the laptop terminal out of the picture, because the Console session fails too.

### Step 1: isolate (2 minutes, $0)
Systems Manager → Session Manager → **Preferences** → Edit:
- Untick **S3 logging**, save.
- Start a new session from the Console (EC2 → Connect → Session Manager).

**Opens and stays open:** logging is the cause. Go to Step 2.
**Still terminates:** logging is not the cause. Reboot the instance, wait 3 minutes, confirm Online, retry.

### Step 2: fix logging properly
1. **Separate bucket (recommended):** create a new session-log bucket in ap-south-1, e.g. `lab3-session-logs-akash`:
   - Block Public Access: all four on
   - Default encryption: SSE-S3
   - Lifecycle: expire after 365 days
   - Tag `Project=aws-practice`
2. **Role policy** on the instance role (replace the bucket name if you use the new one):
   - `s3:PutObject` on `arn:aws:s3:::<bucket>/sessions/*`
   - `s3:GetEncryptionConfiguration` on `arn:aws:s3:::<bucket>`
3. **Preferences:** bucket = the log bucket, S3 key prefix = `sessions` (no leading slash), keep "Enforce S3 log encryption" ticked.
4. Re-enable logging and start a new session.

### Step 3: read the real reason (once any session opens)
```
sudo ls -t /var/log/amazon/ssm/ssm-session-worker/ | head -3
sudo grep -iE "error|denied|s3|encrypt" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 20
```
Paste what you see. If no session opens even with logging off, paste the `describe-sessions --state History` output instead.

### Cost
The three interface endpoints are still billing (~$0.033/hr). You are likely about 2.5 hours in, so around $0.08 so far, well inside the USD 1 cap. If this isn't solved in about 20 minutes, delete the interface endpoints (keep the free S3 gateway one) and recreate them later for a few cents. Never leave them overnight (~$0.80).

### Self-check
- Why does the Console failing too rule out the laptop plugin?
- Why would the agent end a session instead of running it without logs?

**Exam relevance (SAP-C03):** when logging is mandatory, Session Manager fails closed. The instance role needs both write access and the ability to read the bucket's encryption config.

Tell me whether the session opens with S3 logging unticked.

---

**You** (24 Nov 2026, 1:16 pm)

now it works after untick

---

**Tutor** (24 Nov 2026, 1:16 pm)

## Confirmed: S3 logging was the cause

Sessions open with logging off, so the network, endpoints, role and agent are all healthy. The agent refuses to run a session when it can't write the log, which is the "fail closed" behaviour the auditors want. Keep logging mandatory in the end. Logging off was a test only.

### Step 1: read the exact reason (30 seconds, optional but valuable)
Inside the working session:
```
sudo grep -iE "s3|denied|encrypt|bucket" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 15
sudo ls -t /var/log/amazon/ssm/ssm-session-worker/ | head -3
```
The most likely message is an AccessDenied on `s3:GetEncryptionConfiguration` or `s3:PutObject`. Paste it if you like, since reading agent errors is a skill interviewers like.

### Step 2: fix it with a dedicated bucket
1. Create `lab3-session-logs-akash` (ap-south-1):
   - Block Public Access: all four on
   - Default encryption: SSE-S3
   - Lifecycle: expire after 365 days
   - Tag `Project=aws-practice`
2. Add this to the instance role's custom policy:
   - `s3:PutObject` on `arn:aws:s3:::lab3-session-logs-akash/sessions/*`
   - `s3:GetEncryptionConfiguration` on `arn:aws:s3:::lab3-session-logs-akash`
3. Preferences: tick S3 logging, bucket = the new one, prefix = `sessions` (no leading slash), keep "Enforce S3 log encryption" ticked. Save.

### Step 3: test
1. Start a **new** session, run `whoami`, `ls /`, `uptime`, then `exit`.
2. Wait 1-2 minutes, then from your laptop:
   ```
   aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive
   ```
3. Download one object with `aws s3 cp` and read it. That is the auditors' record of what was typed.

If the session closes again, the policy is still missing something. Untick logging, read the agent log lines from Step 1, and fix what they name.

### Then finish the checklist
- `curl -m 5 https://www.google.com` times out (did you run this yet?)
- `ec2-sg` inbound returns `[]` and carries the `Project=aws-practice` tag
- Terminate and replace the instance, and time how long it takes to show Online
- Delete the three interface endpoints, then run the clean-delete checks

### Cost
The three interface endpoints still bill about $0.033/hr. You are around 2.5-3 hours in, so roughly $0.09 so far, well inside the USD 1 cap. Delete them as soon as the replacement test is done. Overnight would cost about $0.80.

### Self-check
- Why is turning logging off acceptable as a test but not as the fix?
- Which two permissions did the instance role need for encrypted S3 session logs?

**Exam relevance (SAP-C03):** mandatory session logging with S3 encryption needs the instance role to write objects and read the bucket's encryption config. CloudTrail still records who started the session.

Tell me what the agent log says, and whether the transcript shows up in the new bucket.

---

**You** (24 Nov 2026, 1:16 pm)

sh-5.2$ sudo grep -iE "s3|denied|encrypt|bucket" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 15
sudo ls -t /var/log/amazon/ssm/ssm-session-worker/ | head -3
2026-11-24 07:39:13.4730 WARN [ssm-session-worker] [akash-y75vi7vj4joz36xcelz9brfaxi] [DataBackend] [pluginName=Standard_Stream] Overriding SessionLogsDestination: "none" since logging session data to CloudWatch or S3 is enabled.
2026-11-24 07:39:13.5147 ERROR [ssm-session-worker] [akash-y75vi7vj4joz36xcelz9brfaxi] [DataBackend] [pluginName=Standard_Stream] Encountered an error while calling S3 API GetBucketEncryption operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: JJ963T3GFA4JVKKB, HostID: EzDjiqiBD/+m21HSSa4E7ZpyFo2M0OkPNR/UcJWWGUSx+njR7cy3ugRvdCT4xPWELrJ6thDC9Es=, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:39:13.5148 ERROR [ssm-session-worker] [akash-y75vi7vj4joz36xcelz9brfaxi] [DataBackend] [pluginName=Standard_Stream] Validation failed, err: Couldn't start the session because we are unable to validate encryption on Amazon S3 bucket. Error: operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: JJ963T3GFA4JVKKB, HostID: EzDjiqiBD/+m21HSSa4E7ZpyFo2M0OkPNR/UcJWWGUSx+njR7cy3ugRvdCT4xPWELrJ6thDC9Es=, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:42:55.8635 INFO [ssm-agent-worker] [MessageService] [MGSInteractor] Parsing AgentMessage aafd2a6d-ed09-4f16-be8c-d10ce13e80eb, Payload: {"schemaVersion":1,"taskId":"908402822288:akash-9yjfi729u2s6g7ghcl9n7idati","topic":"test_topic","content":"{\"RunAsUser\":\"\",\"Parameters\":{},\"DocumentContent\":{\"schemaVersion\":\"1.0\",\"inputs\":{\"cloudWatchEncryptionEnabled\":true,\"s3EncryptionEnabled\":true,\"maxSessionDuration\":\"\",\"runAsDefaultUser\":\"\",\"s3BucketName\":\"lab3-cloudtrail-bucket-akash\",\"cloudWatchStreamingEnabled\":true,\"kmsKeyId\":\"\",\"runAsEnabled\":false,\"idleSessionTimeout\":\"20\",\"s3KeyPrefix\":\"sessions\",\"shellProfile\":{\"linux\":\"\",\"windows\":\"\"},\"cloudWatchLogGroupName\":\"\"},\"description\":\"Document to hold regional settings for Session Manager\",\"sessionType\":\"Standard_Stream\"},\"SessionOwner\":\"arn:aws:iam::908402822288:user/akash\",\"SessionId\":\"akash-9yjfi729u2s6g7ghcl9n7idati\"}"}
2026-11-24 07:42:55.9037 INFO [ssm-session-worker] [akash-9yjfi729u2s6g7ghcl9n7idati] [DataBackend] {"DocumentInformation":{"DocumentID":"akash-9yjfi729u2s6g7ghcl9n7idati","CommandID":"akash-9yjfi729u2s6g7ghcl9n7idati","AssociationID":"","InstanceID":"i-034eaffd299e9c196","MessageID":"akash-9yjfi729u2s6g7ghcl9n7idati","RunID":"2026-11-24T07-42-55.863Z","CreatedDate":"58867-04-29 11:31:02 +0000 UTC","DocumentName":"","DocumentVersion":"","DocumentStatus":"InProgress","RunCount":0,"ProcInfo":{"Pid":2995,"StartTime":"2026-11-24T07:42:55.864497883Z"},"ClientId":"","RunAsUser":"","SessionOwner":"arn:aws:iam::908402822288:user/akash"},"DocumentType":"StartSession","SchemaVersion":"1.0","InstancePluginsInformation":[{"Configuration":{"Settings":null,"Properties":null,"OutputS3KeyPrefix":"sessions","OutputS3BucketName":"lab3-cloudtrail-bucket-akash","S3EncryptionEnabled":true,"CloudWatchLogGroup":"","CloudWatchEncryptionEnabled":true,"CloudWatchStreamingEnabled":true,"OrchestrationDirectory":"/var/lib/amazon/ssm/i-034eaffd299e9c196/session/orchestration/akash-9yjfi729u2s6g7ghcl9n7idati/Standard_Stream","MessageId":"akash-9yjfi729u2s6g7ghcl9n7idati","BookKeepingFileName":"akash-9yjfi729u2s6g7ghcl9n7idati","PluginName":"Standard_Stream","PluginID":"Standard_Stream","DefaultWorkingDirectory":"","Preconditions":null,"IsPreconditionEnabled":false,"CurrentAssociations":null,"SessionId":"akash-9yjfi729u2s6g7ghcl9n7idati","ClientId":"","KmsKeyId":"","RunAsEnabled":false,"RunAsUser":"","ShellProfile":{"windows":"","linux":""},"SessionOwner":"arn:aws:iam::908402822288:user/akash","UpstreamServiceName":"","EnvironmentVariables":null},"Name":"Standard_Stream","Result":{"pluginID":"","pluginName":"","status":"","code":0,"output":null,"startDateTime":"0001-01-01T00:00:00Z","endDateTime":"0001-01-01T00:00:00Z","outputS3BucketName":"","outputS3KeyPrefix":"","stepName":"","error":"","standardOutput":"","standardError":""},"Id":"Standard_Stream"}],"CancelInformation":{"CancelMessageID":"","CancelCommandID":"","Payload":"","DebugInfo":""},"IOConfig":{"OrchestrationDirectory":"/var/lib/amazon/ssm/i-034eaffd299e9c196/session/orchestration/akash-9yjfi729u2s6g7ghcl9n7idati","OutputS3BucketName":"lab3-cloudtrail-bucket-akash","OutputS3KeyPrefix":"sessions","CloudWatchConfig":{"LogGroupName":"","LogStreamPrefix":"","LogGroupEncryptionEnabled":false}},"UpstreamServiceName":"MessageGatewayService"}
2026-11-24 07:42:55.9701 WARN [ssm-session-worker] [akash-9yjfi729u2s6g7ghcl9n7idati] [DataBackend] [pluginName=Standard_Stream] Overriding SessionLogsDestination: "none" since logging session data to CloudWatch or S3 is enabled.
2026-11-24 07:42:56.0049 ERROR [ssm-session-worker] [akash-9yjfi729u2s6g7ghcl9n7idati] [DataBackend] [pluginName=Standard_Stream] Encountered an error while calling S3 API GetBucketEncryption operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: T3ZEQMQGZMDDMBCJ, HostID: bkBOb5TXk2id3BLu8i8Bnj923mh5UcT9K6NtquIYCQUi94q22CgbQu7gq97QYcDpRdgBOKiZ7IYxkaYBqLDErAaV0ei/JDzW, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:42:56.0049 ERROR [ssm-session-worker] [akash-9yjfi729u2s6g7ghcl9n7idati] [DataBackend] [pluginName=Standard_Stream] Validation failed, err: Couldn't start the session because we are unable to validate encryption on Amazon S3 bucket. Error: operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: T3ZEQMQGZMDDMBCJ, HostID: bkBOb5TXk2id3BLu8i8Bnj923mh5UcT9K6NtquIYCQUi94q22CgbQu7gq97QYcDpRdgBOKiZ7IYxkaYBqLDErAaV0ei/JDzW, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:44:19.2271 INFO [ssm-agent-worker] [MessageService] [MGSInteractor] Parsing AgentMessage 8ec40fd2-ec3f-426a-b412-4fdce7d19b0e, Payload: {"schemaVersion":1,"taskId":"908402822288:akash-rp8hccatanojp397a7bgft5ncy","topic":"test_topic","content":"{\"RunAsUser\":\"\",\"Parameters\":{},\"DocumentContent\":{\"schemaVersion\":\"1.0\",\"inputs\":{\"cloudWatchEncryptionEnabled\":true,\"s3EncryptionEnabled\":true,\"maxSessionDuration\":\"\",\"runAsDefaultUser\":\"\",\"s3BucketName\":\"lab3-cloudtrail-bucket-akash\",\"cloudWatchStreamingEnabled\":true,\"kmsKeyId\":\"\",\"runAsEnabled\":false,\"idleSessionTimeout\":\"20\",\"s3KeyPrefix\":\"sessions\",\"shellProfile\":{\"linux\":\"\",\"windows\":\"\"},\"cloudWatchLogGroupName\":\"\"},\"description\":\"Document to hold regional settings for Session Manager\",\"sessionType\":\"Standard_Stream\"},\"SessionOwner\":\"arn:aws:iam::908402822288:user/akash\",\"SessionId\":\"akash-rp8hccatanojp397a7bgft5ncy\"}"}
2026-11-24 07:44:19.2689 INFO [ssm-session-worker] [akash-rp8hccatanojp397a7bgft5ncy] [DataBackend] {"DocumentInformation":{"DocumentID":"akash-rp8hccatanojp397a7bgft5ncy","CommandID":"akash-rp8hccatanojp397a7bgft5ncy","AssociationID":"","InstanceID":"i-034eaffd299e9c196","MessageID":"akash-rp8hccatanojp397a7bgft5ncy","RunID":"2026-11-24T07-44-19.227Z","CreatedDate":"58867-04-30 10:40:26 +0000 UTC","DocumentName":"","DocumentVersion":"","DocumentStatus":"InProgress","RunCount":0,"ProcInfo":{"Pid":3060,"StartTime":"2026-11-24T07:44:19.228135226Z"},"ClientId":"","RunAsUser":"","SessionOwner":"arn:aws:iam::908402822288:user/akash"},"DocumentType":"StartSession","SchemaVersion":"1.0","InstancePluginsInformation":[{"Configuration":{"Settings":null,"Properties":null,"OutputS3KeyPrefix":"sessions","OutputS3BucketName":"lab3-cloudtrail-bucket-akash","S3EncryptionEnabled":true,"CloudWatchLogGroup":"","CloudWatchEncryptionEnabled":true,"CloudWatchStreamingEnabled":true,"OrchestrationDirectory":"/var/lib/amazon/ssm/i-034eaffd299e9c196/session/orchestration/akash-rp8hccatanojp397a7bgft5ncy/Standard_Stream","MessageId"

---

**Tutor** (24 Nov 2026, 1:16 pm)

## Root cause confirmed, straight from the agent log

```
AccessDenied: assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform:
s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash"
because no identity-based policy allows the s3:GetEncryptionConfiguration action
```

- Session Manager has "Enforce S3 log encryption" on, so before starting a shell the agent calls `GetBucketEncryption` on the log bucket.
- Your instance role (`lab3-ec2-ssm`) has no permission for that call, so the agent refuses to start the session. This is the fail-closed behaviour.
- Also note `Overriding SessionLogsDestination: "none"`. It just means logging was turned on, which is expected.
- The same log also shows your `s3KeyPrefix` is now `sessions` with no leading slash. Good.

You guessed the right permission two messages ago. Now the log proves it, which is the habit to build: read the exact error, then fix only what it names.

## Fix

### 1. Create a separate session-log bucket (about $0)
`lab3-session-logs-akash`, ap-south-1:
- Block Public Access: all four on
- Default encryption: SSE-S3
- Lifecycle: expire after 365 days
- Tag `Project=aws-practice`

The `lab3-cloudtrail-bucket-akash` bucket should stay for CloudTrail only.

### 2. Add a statement to the role's custom policy
```json
{
  "Effect": "Allow",
  "Action": "s3:GetEncryptionConfiguration",
  "Resource": "arn:aws:s3:::lab3-session-logs-akash"
}
```
- This one is on the **bucket ARN** (no `/*`), because it is a bucket-level action.
- Keep `s3:PutObject` on `arn:aws:s3:::lab3-session-logs-akash/sessions/*`. That one is on objects, so it needs the `/*`.

### 3. Point Preferences at the new bucket
Session Manager → Preferences → Edit: tick S3 logging, bucket `lab3-session-logs-akash`, prefix `sessions`, keep "Enforce S3 log encryption" ticked. Save.

### 4. Test
1. Start a new session (Console or CLI), run `whoami`, `ls /`, `uptime`, then `exit`.
2. Wait 1-2 minutes, then from your laptop:
   ```
   aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive
   ```
3. Download the object with `aws s3 cp` and read it. That is the auditors' "who typed what" record.

Role policy changes apply within seconds, so no reboot is needed.

## Then finish the checklist
- `curl -m 5 https://www.google.com` times out inside a session
- `ec2-sg` inbound returns `[]` and carries the tag
- Terminate and replace the instance, and time it to Online
- Delete the three interface endpoints, then run the clean-delete checks, including emptying and deleting both buckets

## Cost
Interface endpoints still bill about $0.033/hr. You're probably around 3 hours in, so roughly $0.10 so far, well inside the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

## Self-check
- Why is `GetEncryptionConfiguration` on the bucket ARN, but `PutObject` on `bucket/sessions/*`?
- Which identity made the denied call: you, or the instance role? How did the log tell you?

**Exam relevance (SAP-C03):** enforcing encrypted session logs needs the instance role to read the bucket's encryption config as well as write objects. CloudTrail still records who started each session.

Tell me whether the transcript appears in the new bucket.

---

**You** (24 Nov 2026, 1:28 pm)

sh-5.2$ aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive


aws: [ERROR]: An error occurred (AccessDenied) when calling the ListObjectsV2 operation: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:ListBucket on resource: "arn:aws:s3:::lab3-session-logs-akash" because no identity-based policy allows the s3:ListBucket action
sh-5.2$ 
sh-5.2$

---

**Tutor** (24 Nov 2026, 1:28 pm)

## This AccessDenied is correct and healthy

```
assumed-role/lab3-ec2-ssm/... is not authorized to perform: s3:ListBucket
```

- You ran the command **inside the server**, so it used the **instance role**.
- The role only has `PutObject` and `GetEncryptionConfiguration` on the log bucket. That is least privilege working as designed.
- The server should be able to write its own logs but not list or read them. Otherwise anyone with a shell could read or tamper with other people's transcripts. **Do not add `s3:ListBucket` to the role.** That would weaken the audit design.

Notice that the denial is on `lab3-session-logs-akash`, so your Preferences and policy now point at the new bucket.

### How to check the transcripts
Run this from your **laptop PowerShell**, which uses your IAM user (`user/akash`):
```
aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive
```
Then download one and read it:
```
aws s3 cp s3://lab3-session-logs-akash/sessions/<object-key> .\session-log.txt
type .\session-log.txt
```
Replace `<object-key>` with the real name from the listing, with no angle brackets.

If the laptop listing is empty, make sure you ran `exit` in a session **after** logging was re-enabled, then wait 1-2 minutes. If the session itself fails to open, re-read the agent log for the named error.

### Earlier test needs a rethink
The checklist item "inside the session, `aws s3 ls s3://<your-log-bucket>` succeeds" proves the S3 gateway endpoint. With this least-privilege role it will be denied on the log bucket. To prove the gateway endpoint path instead, copy a tiny file up from inside the session:
```
echo test > /tmp/t.txt
aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt
```
- **Success** means the server reached S3 privately through the gateway endpoint, with no internet path.
- **Hang or timeout** means the gateway endpoint isn't attached to your route table.

Delete that test file afterwards from your laptop.

### Still to do
- `curl -m 5 https://www.google.com` times out (don't skip it)
- `ec2-sg` inbound returns `[]` and has the tag
- Terminate and replace the instance, then time it to Online
- Delete the three interface endpoints, then the clean-delete checks

### Cost
Interface endpoints still bill about $0.033/hr. You are roughly 3+ hours in, so around $0.10-0.12 so far, well inside the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

### Self-check
- Why is it good that the instance role can write session logs but not list them?
- Who should be able to read the transcripts, and how would you grant it (the admin group, or a separate auditor role)?

**Exam relevance (SAP-C03):** separate write permission (the instance role) from read permission (auditors) for audit logs. Pair this with S3 Object Lock or versioning when tamper-resistance is required.

Paste the laptop-side listing and the `gateway-test` result.

---

**You** (24 Nov 2026, 1:28 pm)

PS C:\Users\asgha\Desktop\AWS> aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive
>> 
PS C:\Users\asgha\Desktop\AWS> aws s3 cp s3://lab3-session-logs-akash/sessions/<object-key> .\session-log.txt
>> type .\session-log.txt
>> 
fatal error: An error occurred (404) when calling the HeadObject operation: Key "sessions/<object-key>" does not exist
type : Cannot find path 'C:\Users\asgha\Desktop\AWS\session-log.txt' because it does not exist.
At line:2 char:1
+ type .\session-log.txt
+ ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (C:\Users\asgha\...session-log.txt:String) [Get-Content], ItemNotFoundException
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetContentCommand
 
PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:29 pm)

## Two separate things here

### 1. The 404 is the placeholder again
`<object-key>` was literal text, so S3 looked for a key with that name. It doesn't exist. Never copy until a listing shows a real key.

### 2. The real finding: the listing is empty, so no transcript exists yet
Your laptop `aws s3 ls ... --recursive` returned nothing and no error. Your user can list the bucket, so the bucket is simply empty. Likely reasons, most likely first:
- **No session has completed since logging was re-enabled with the new bucket.** The transcript uploads when the session ends. Start a new session, run `whoami`, `ls /`, `uptime`, then type `exit`. Don't just close the window.
- **The session fails to start.** If it closes straight away, read the agent log again for the named error (often a missing permission).
- **The role is missing `s3:PutObject`** on `arn:aws:s3:::lab3-session-logs-akash/sessions/*`. This is the one I'd check first. You earlier had PutObject only on the old bucket.

### Quick checks
1. Confirm the new session opens a shell with logging on. If it does, `GetEncryptionConfiguration` is fine.
2. After `exit`, wait 1-2 minutes, then from your laptop:
   ```
   aws s3 ls s3://lab3-session-logs-akash/ --recursive
   ```
   (whole bucket, no prefix, in case the key landed elsewhere).
3. If still empty, from a session on the server:
   ```
   sudo grep -iE "PutObject|upload|AccessDenied" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 10
   sudo grep -riE "AccessDenied|PutObject" /var/log/amazon/ssm/ssm-session-worker/ 2>/dev/null | tail -n 10
   ```
   The error will name the exact action and resource to fix.

### Gateway endpoint test (still to do)
Inside a session:
```
echo test > /tmp/t.txt
aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt
```
Success means the server reached S3 privately via the gateway endpoint, and it also proves `PutObject` works on the new bucket. If it says AccessDenied on PutObject, that's your missing permission. If it hangs, check that the gateway endpoint is attached to your route table. Delete the test file afterwards from your laptop.

### Cost
The interface endpoints are still billing (~$0.033/hr). You're about 3+ hours in, roughly $0.10-0.12, well under the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

### Self-check
- Why does the transcript only appear after `exit`?
- What does a successful `aws s3 cp` from the server prove about the network path?

**Exam relevance (SAP-C03):** session logs need the instance role to hold both `PutObject` and `GetEncryptionConfiguration`. Read access for auditors belongs to a separate identity.

Paste the result of the `aws s3 cp` test and the whole-bucket listing.

---

**You** (24 Nov 2026, 1:29 pm)

sh-5.2$ sudo grep -iE "PutObject|upload|AccessDenied" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 10
sudo grep -riE "AccessDenied|PutObject" /var/log/amazon/ssm/ssm-session-worker/ 2>/dev/null | tail -n 10
2026-11-24 07:36:50.7312 ERROR [ssm-session-worker] [akash-kylxl3ogcn5o666cf394jtetaa] [DataBackend] [pluginName=Standard_Stream] Validation failed, err: Couldn't start the session because we are unable to validate encryption on Amazon S3 bucket. Error: operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: 698XW7JCV6WMJR9F, HostID: GhhPHQIZdGIdLrCU+wtceIMEYzxgkECsB49NU77+nvV/cTOOGyxXYthTYfStLpiiMZyOTb0KvH8pVF5aKY8SQjtFVBcXKmEt, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:39:13.5147 ERROR [ssm-session-worker] [akash-y75vi7vj4joz36xcelz9brfaxi] [DataBackend] [pluginName=Standard_Stream] Encountered an error while calling S3 API GetBucketEncryption operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: JJ963T3GFA4JVKKB, HostID: EzDjiqiBD/+m21HSSa4E7ZpyFo2M0OkPNR/UcJWWGUSx+njR7cy3ugRvdCT4xPWELrJ6thDC9Es=, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:39:13.5148 ERROR [ssm-session-worker] [akash-y75vi7vj4joz36xcelz9brfaxi] [DataBackend] [pluginName=Standard_Stream] Validation failed, err: Couldn't start the session because we are unable to validate encryption on Amazon S3 bucket. Error: operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: JJ963T3GFA4JVKKB, HostID: EzDjiqiBD/+m21HSSa4E7ZpyFo2M0OkPNR/UcJWWGUSx+njR7cy3ugRvdCT4xPWELrJ6thDC9Es=, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:42:56.0049 ERROR [ssm-session-worker] [akash-9yjfi729u2s6g7ghcl9n7idati] [DataBackend] [pluginName=Standard_Stream] Encountered an error while calling S3 API GetBucketEncryption operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: T3ZEQMQGZMDDMBCJ, HostID: bkBOb5TXk2id3BLu8i8Bnj923mh5UcT9K6NtquIYCQUi94q22CgbQu7gq97QYcDpRdgBOKiZ7IYxkaYBqLDErAaV0ei/JDzW, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:42:56.0049 ERROR [ssm-session-worker] [akash-9yjfi729u2s6g7ghcl9n7idati] [DataBackend] [pluginName=Standard_Stream] Validation failed, err: Couldn't start the session because we are unable to validate encryption on Amazon S3 bucket. Error: operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: T3ZEQMQGZMDDMBCJ, HostID: bkBOb5TXk2id3BLu8i8Bnj923mh5UcT9K6NtquIYCQUi94q22CgbQu7gq97QYcDpRdgBOKiZ7IYxkaYBqLDErAaV0ei/JDzW, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:44:19.3690 ERROR [ssm-session-worker] [akash-rp8hccatanojp397a7bgft5ncy] [DataBackend] [pluginName=Standard_Stream] Encountered an error while calling S3 API GetBucketEncryption operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: CGG2MW532GW20SBN, HostID: YqMvzV21jvubl0rsxqZk7kNA1w6HpdaYT0bqtIJEy00zglnBFLZbukEuo6YOqo0sDQ7sRMiFaKxZyFdlkBaDwMRN0Bo5noMC, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:44:19.3690 ERROR [ssm-session-worker] [akash-rp8hccatanojp397a7bgft5ncy] [DataBackend] [pluginName=Standard_Stream] Validation failed, err: Couldn't start the session because we are unable to validate encryption on Amazon S3 bucket. Error: operation error S3: GetBucketEncryption, https response error StatusCode: 403, RequestID: CGG2MW532GW20SBN, HostID: YqMvzV21jvubl0rsxqZk7kNA1w6HpdaYT0bqtIJEy00zglnBFLZbukEuo6YOqo0sDQ7sRMiFaKxZyFdlkBaDwMRN0Bo5noMC, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:GetEncryptionConfiguration on resource: "arn:aws:s3:::lab3-cloudtrail-bucket-akash" because no identity-based policy allows the s3:GetEncryptionConfiguration action
2026-11-24 07:59:10.5775 INFO [ssm-session-worker] [akash-vk4grh8uey24pei668oxris3n4] [DataBackend] [pluginName=Standard_Stream] Uploading /var/lib/amazon/ssm/i-034eaffd299e9c196/session/orchestration/akash-vk4grh8uey24pei668oxris3n4/Standard_Stream/logTempFileProcessed.log to s3://lab3-session-logs-akash/sessions/akash-vk4grh8uey24pei668oxris3n4.log
2026-11-24 07:59:10.6092 ERROR [ssm-session-worker] [akash-vk4grh8uey24pei668oxris3n4] [DataBackend] [pluginName=Standard_Stream] Failed to upload /var/lib/amazon/ssm/i-034eaffd299e9c196/session/orchestration/akash-vk4grh8uey24pei668oxris3n4/Standard_Stream/logTempFileProcessed.log to s3://lab3-session-logs-akash/sessions/akash-vk4grh8uey24pei668oxris3n4.log err:operation error S3: PutObject, https response error StatusCode: 403, RequestID: SVTCTVFXXXB1EGZV, HostID: wqtiv7wuEdpdEBnc3m9SUWS8C+ac+yV9usvnDYa3E8/TMUng4Vmv2ZpPOG7HkkPhKloTcAkESByIRRIRta4HdxshA8Yp/tld, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:PutObject on resource: "arn:aws:s3:::lab3-session-logs-akash/sessions/akash-vk4grh8uey24pei668oxris3n4.log" because no identity-based policy allows the s3:PutObject action
2026-11-24 07:59:10.6092 ERROR [ssm-session-worker] [akash-vk4grh8uey24pei668oxris3n4] [DataBackend] [pluginName=Standard_Stream] Failed to upload shell session logs to S3: operation error S3: PutObject, https response error StatusCode: 403, RequestID: SVTCTVFXXXB1EGZV, HostID: wqtiv7wuEdpdEBnc3m9SUWS8C+ac+yV9usvnDYa3E8/TMUng4Vmv2ZpPOG7HkkPhKloTcAkESByIRRIRta4HdxshA8Yp/tld, api error AccessDenied: User: arn:aws:sts::908402822288:assumed-role/lab3-ec2-ssm/i-034eaffd299e9c196 is not authorized to perform: s3:PutObject on resource: "arn:aws:s3:::lab3-session-logs-akash/sessions/akash-vk4grh8uey24pei668oxris3n4.log" because no identity-based policy allows the s3:PutObject action
sh-5.2$

---

**Tutor** (24 Nov 2026, 1:29 pm)

## Found it: the last error names the missing piece

```
Failed to upload ... to s3://lab3-session-logs-akash/sessions/akash-vk4grh8uey24pei668oxris3n4.log
api error AccessDenied: assumed-role/lab3-ec2-ssm/... is not authorized to perform:
s3:PutObject on resource: "arn:aws:s3:::lab3-session-logs-akash/sessions/akash-vk4grh8uey24pei668oxris3n4.log"
```

### What the log tells us (in order)
- **07:36-07:44:** sessions died on `GetEncryptionConfiguration` for the **old** bucket (`lab3-cloudtrail-bucket-akash`). That is the old problem, already explained.
- **07:59:** the session **opened** against the new bucket. So `GetEncryptionConfiguration` on `lab3-session-logs-akash` is now allowed. Progress.
- **07:59:10:** the agent tried to upload the transcript and got denied on `s3:PutObject`. The role has no PutObject permission for the **new** bucket. Your old PutObject statement still points at the old bucket name.

This is the point I flagged earlier: the old statement doesn't cover the new bucket. The fix is one small edit.

### Fix: update the role's custom policy
IAM → Roles → `lab3-ec2-ssm` → the custom inline or managed policy → Edit. Make sure it contains:
```json
{
  "Effect": "Allow",
  "Action": "s3:PutObject",
  "Resource": "arn:aws:s3:::lab3-session-logs-akash/sessions/*"
}
```
- Object-level action, so the ARN ends in `/sessions/*`.
- Keep the `GetEncryptionConfiguration` statement on `arn:aws:s3:::lab3-session-logs-akash` (no `/*`).
- You can remove the old bucket's statements, since that bucket is for CloudTrail only.

Policy changes apply within seconds, so no reboot is needed.

### Test
1. Start a new session, run `whoami`, `ls /`, `uptime`, then `exit`.
2. Wait about a minute, then from your **laptop**:
   ```
   aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive
   ```
3. Copy the **real** key shown in the listing:
   ```
   aws s3 cp s3://lab3-session-logs-akash/sessions/akash-xxxx.log .\session-log.txt
   type .\session-log.txt
   ```
   (Replace `akash-xxxx.log` with the actual name from the listing.)

The transcript from the failed 07:59 session is lost, since the temp file was not uploaded. Just run a new session.

### Then the gateway endpoint test
Inside a session:
```
echo test > /tmp/t.txt
aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt
```
Success proves private S3 access through the gateway endpoint. Delete the file afterwards from your laptop.

### Cost
Interface endpoints still bill about $0.033/hr. You are around 3.5 hours in, so roughly $0.12-0.15 total, well under the USD 1 cap. Delete the three interface endpoints right after the replacement test. Overnight would be about $0.80.

### Self-check
- Which two log lines prove the `GetEncryptionConfiguration` fix worked but `PutObject` did not?
- Why does a statement on the old bucket's ARN not cover the new bucket?

**Exam relevance (SAP-C03):** the agent writes transcripts with the instance role, so write permission must match the exact bucket and prefix in Session Manager preferences. Auditor read access belongs to a separate identity.

Paste the laptop-side listing after your next session.

---

**You** (24 Nov 2026, 1:30 pm)

{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::lab3-cloudtrail-bucket-akash/logs"
		},
		{
			"Sid": "VisualEditor1",
			"Effect": "Allow",
			"Action": [
				"s3:ListObjectAnnotations",
				"s3:ListTagsForResource",
				"s3:ListBucketMultipartUploads",
				"s3:ListAccessGrants",
				"s3:ListCallerAccessGrants",
				"s3:ListBucketVersions",
				"s3:ListBucket",
				"s3:ListAccessGrantsLocations",
				"s3:ListObjectVersionAnnotations",
				"s3:ListMultipartUploadParts"
			],
			"Resource": "arn:aws:s3:::lab3-cloudtrail-bucket-akash"
		},
		{
			"Sid": "VisualEditor2",
			"Effect": "Allow",
			"Action": [
				"s3:ListStorageLensConfigurations",
				"s3:ListAccessPointsForObjectLambda",
				"s3:ListAllMyBuckets",
				"s3:ListAccessPoints",
				"s3:ListAccessGrantsInstances",
				"s3:ListJobs",
				"s3:ListMultiRegionAccessPoints",
				"s3:ListStorageLensGroups"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "s3:GetEncryptionConfiguration",
			"Resource": "arn:aws:s3:::lab3-session-logs-akash"
		},

	]
}

---

**Tutor** (24 Nov 2026, 1:30 pm)

## Your policy is close, but it has 3 problems

### 1. PutObject still points at the wrong bucket (this is the actual blocker)
```
"Resource": "arn:aws:s3:::lab3-cloudtrail-bucket-akash/logs"
```
Three issues in one line:
- Wrong bucket: it must be `lab3-session-logs-akash`.
- Wrong prefix: Session Manager writes to `sessions/`, not `logs`.
- No `/*`: `.../logs` matches only one object named exactly `logs`. A prefix needs `/logs/*`.

### 2. The Visual Editor's List* statements are too broad
`VisualEditor1` and `VisualEditor2` grant dozens of list actions, including `ListAllMyBuckets` on `*`. The agent needs none of them. They also let anyone with a shell enumerate your buckets. Delete both statements. This matches the least-privilege point from earlier.

### 3. Trailing comma makes the JSON invalid
After the last statement's `}` there is a `,`. IAM will reject it. Remove it.

## Replace the whole policy with this
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WriteSessionLogs",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::lab3-session-logs-akash/sessions/*"
    },
    {
      "Sid": "ValidateLogBucketEncryption",
      "Effect": "Allow",
      "Action": "s3:GetEncryptionConfiguration",
      "Resource": "arn:aws:s3:::lab3-session-logs-akash"
    }
  ]
}
```
This is just the fix for your existing policy, not a new design. Keep `AmazonSSMManagedInstanceCore` attached as it is.

If you use the IAM policy validator or the JSON tab, it will flag the trailing comma. Save and it applies within seconds.

## Then test
1. Start a new session, run `whoami`, `ls /`, `uptime`, then `exit`.
2. Wait about a minute, then from your **laptop**:
   ```
   aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive
   ```
3. Copy the **real** key from the listing into `aws s3 cp ... .\session-log.txt` and read it.
4. Gateway endpoint test inside a session:
   ```
   echo test > /tmp/t.txt
   aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt
   ```
   Delete the test file afterwards from your laptop.

## Cost
The interface endpoints are still billing (~$0.033/hr). You are roughly 3.5-4 hours in, about $0.15 total, well under the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

## Self-check
- Why does `.../logs` not match `.../logs/file.txt`, and what does `/*` change?
- Which of the three problems would have stopped the upload even if the other two were fixed?

**Exam relevance (SAP-C03):** object-level actions need an object ARN (`bucket/prefix/*`), bucket-level actions need the bucket ARN. Mixing them is a classic IAM trap.

Paste the laptop-side listing after your next session.

---

**You** (24 Nov 2026, 1:32 pm)

PS C:\Users\asgha\Desktop\AWS> aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive                  
>>                       
PS C:\Users\asgha\Desktop\AWS> aws s3 cp s3://lab3-session-logs-akash/sessions/temp .\session-log.txt        
>> type .\session-log.txt
>> 
fatal error: An error occurred (404) when calling the HeadObject operation: Key "sessions/temp" does not exist
type : Cannot find path 'C:\Users\asgha\Desktop\AWS\session-log.txt' because it does not exist.
At line:2 char:1
+ type .\session-log.txt
+ ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (C:\Users\asgha\...session-log.txt:String) [Get-Content], ItemNotFoundException
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetContentCommand
 
PS C:\Users\asgha\Desktop\AWS> aws s3 cp s3://lab3-session-logs-akash/sessions/temp.txt .\session-log.txt
>> type .\session-log.txt
>> 
fatal error: An error occurred (404) when calling the HeadObject operation: Key "sessions/temp.txt" does not exist
type : Cannot find path 'C:\Users\asgha\Desktop\AWS\session-log.txt' because it does not exist.
At line:2 char:1
+ type .\session-log.txt
+ ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (C:\Users\asgha\...session-log.txt:String) [Get-Content], ItemNotFoundException
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetContentCommand
 
PS C:\Users\asgha\Desktop\AWS> aws s3 ls s3://lab3-session-logs-akash/sessions/ --recursive              
>>                       
PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:32 pm)

## The listing is still empty, and the two 404s are you guessing key names

`sessions/temp` and `sessions/temp.txt` don't exist because **you invented those names**. Never `cp` until `ls` shows a real key. The agent names files after the session ID, like `akash-vk4grh8uey24pei668oxris3n4.log`.

The real question is why `ls` shows nothing. I need facts, not guesses.

### Step 1: did you save the new policy?
Did you replace the policy with the corrected JSON (PutObject on `lab3-session-logs-akash/sessions/*`)? If you only looked at it, the old wrong `PutObject` is still in place. Check:
```
aws iam list-role-policies --role-name lab3-ec2-ssm
aws iam get-role-policy --role-name lab3-ec2-ssm --policy-name <policy-name>
```
(`<policy-name>` is a placeholder. Use the name returned by the first command. If the policy is a managed one, use `list-attached-role-policies` instead.)

### Step 2: run a clean test session
1. Start a **new** session after saving the policy.
2. Run `whoami`, `uptime`, then type `exit`. Don't close the window or press Ctrl+C.
3. Wait one minute.
4. From your laptop, list the whole bucket, not just the prefix:
   ```
   aws s3 ls s3://lab3-session-logs-akash/ --recursive
   ```

### Step 3: if still empty, read the newest agent error
Inside a session:
```
sudo grep -iE "Uploading|Failed to upload|AccessDenied" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 4
```
- **"Uploading ..." with no "Failed"**: the upload worked, so check the bucket name and region in your `ls`.
- **"Failed ... PutObject AccessDenied"**: the policy still isn't right. Compare the resource in the error with your policy character by character.
- **No new "Uploading" line**: the session didn't end cleanly, or S3 logging is unticked in Preferences. Check that Preferences shows bucket `lab3-session-logs-akash`, prefix `sessions`.

Paste only those few lines, not the whole log.

### Cost
The interface endpoints are still billing (~$0.033/hr). You are about 4 hours in, roughly $0.15-0.20 total, under the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

### Self-check
- Where do you get a real object key from before running `aws s3 cp`?
- Which of the three Step 3 outcomes means the problem is not IAM?

**Exam relevance (SAP-C03):** troubleshoot logging pipelines in order: preference, role permission, then the object in the bucket.

Paste the Step 1 output (or tell me you saved the policy) and the Step 3 lines.

---

**You** (24 Nov 2026, 1:33 pm)

PS C:\Users\asgha\Desktop\AWS> aws iam list-role-policies --role-name lab3-ec2-ssm
>> aws iam get-role-policy --role-name lab3-ec2-ssm --policy-name lab3-ec2-ssm 
{                                                                                                                                                            
    "PolicyNames": [
        "lab3-inline-s3"
    ]
}


aws: [ERROR]: An error occurred (NoSuchEntity) when calling the GetRolePolicy operation: The role policy with name lab3-ec2-ssm cannot be found.
PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:33 pm)

## Good: you now have the real policy name

`list-role-policies` returned `lab3-inline-s3`. The second command failed because you used the role name (`lab3-ec2-ssm`) as the policy name. The two names are different things.

### Step 1: read the saved policy
```
aws iam get-role-policy --role-name lab3-ec2-ssm --policy-name lab3-inline-s3 --query PolicyDocument
```

### What to look for
- **PutObject Resource** must be exactly `arn:aws:s3:::lab3-session-logs-akash/sessions/*`.
- **GetEncryptionConfiguration Resource** must be exactly `arn:aws:s3:::lab3-session-logs-akash`.
- If you still see `lab3-cloudtrail-bucket-akash/logs` or the long list of `List*` actions, your edit was never saved. Open IAM → Roles → `lab3-ec2-ssm` → `lab3-inline-s3` → Edit → JSON tab, paste the corrected policy, and click **Save changes**. Saving is a separate click, and an invalid JSON (like the trailing comma) will refuse to save.

Note that `AmazonSSMManagedInstanceCore` is a separate managed policy and doesn't appear in this list.

### Step 2: clean test
1. Start a new session, run `whoami`, `uptime`, then type `exit`.
2. Wait a minute, then from your laptop:
   ```
   aws s3 ls s3://lab3-session-logs-akash/ --recursive
   ```
3. Copy the real key shown in the listing. Don't type a guessed name.

### Step 3: if still empty
Inside a session:
```
sudo grep -iE "Uploading|Failed to upload" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 4
```
Paste only those lines.

### Cost
The interface endpoints still bill about $0.033/hr. You are about 4 hours in, roughly $0.15-0.20 total, under the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

### Self-check
- What is the difference between a role name and a policy name, and which command lists each?
- Why does the inline policy not show `AmazonSSMManagedInstanceCore`?

**Exam relevance (SAP-C03):** know the difference between inline and managed policies, and how to inspect each with the CLI (`list-role-policies` vs `list-attached-role-policies`).

Paste the `get-role-policy` output.

---

**You** (24 Nov 2026, 1:33 pm)

PS C:\Users\asgha\Desktop\AWS> aws iam list-role-policies --role-name lab3-ec2-ssm
>> aws iam get-role-policy --role-name lab3-ec2-ssm --policy-name lab3-ec2-ssm 
{                                                                                                                                                            
    "PolicyNames": [
        "lab3-inline-s3"
    ]
}


aws: [ERROR]: An error occurred (NoSuchEntity) when calling the GetRolePolicy operation: The role policy with name lab3-ec2-ssm cannot be found.
PS C:\Users\asgha\Desktop\AWS> aws iam get-role-policy --role-name lab3-ec2-ssm --policy-name lab3-inline-s3 --query PolicyDocument
>> 
{                                                                                                                                                            
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "WriteSessionLogs",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::lab3-session-logs-akash/sessions/*"
        },
        {
            "Sid": "ValidateLogBucketEncryption",
            "Effect": "Allow",
            "Action": "s3:GetEncryptionConfiguration",
            "Resource": "arn:aws:s3:::lab3-session-logs-akash"
        }
    ]
}

PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:33 pm)

## The policy is saved correctly

Both statements match what we need:
- `s3:PutObject` on `lab3-session-logs-akash/sessions/*` (object-level, so `/sessions/*`)
- `s3:GetEncryptionConfiguration` on `lab3-session-logs-akash` (bucket-level, no `/*`)

So IAM is no longer the blocker. The 07:59 failure happened **before** you saved this. Nothing has been uploaded since, because no session has ended after the fix.

### Step 1: run one clean session
1. Start a new session:
   ```
   aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
   ```
2. Run `whoami`, `uptime`, `ls /`.
3. Type `exit`. Don't close the window or press Ctrl+C.
4. Wait about a minute.

### Step 2: list the whole bucket from your laptop
```
aws s3 ls s3://lab3-session-logs-akash/ --recursive
```
You should see a key like `sessions/akash-xxxxxxxx.log`. Copy that real name for `aws s3 cp`.

### Step 3: if still empty, read the newest upload line
Open a session and run:
```
sudo grep -iE "Uploading|Failed to upload" /var/log/amazon/ssm/amazon-ssm-agent.log | tail -n 4
```
- "Uploading" with no "Failed": it worked. Re-check the bucket name and region in your `ls`.
- "Failed ... AccessDenied": paste the line. We compare the resource in the error against the policy.
- No new "Uploading" line: confirm Preferences shows S3 logging ticked, bucket `lab3-session-logs-akash`, prefix `sessions`.

Paste only those few lines.

### Then the rest of the checklist
- Gateway endpoint test inside a session:
  ```
  echo test > /tmp/t.txt
  aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt
  ```
  Delete the test file afterwards from your laptop.
- `curl -m 5 https://www.google.com` should time out.
- Check that the `ec2-sg` inbound rules return `[]`.
- Terminate and replace the instance, then time it to Online.
- Delete the three interface endpoints, then run the clean-delete checks (empty and delete both buckets too).

### Cost
Interface endpoints still bill about $0.033/hr. You are about 4 hours in, roughly $0.15-0.20 total, under the USD 1 cap. Delete them right after the replacement test. Overnight would be about $0.80.

### Self-check
- Why did the 07:59 upload fail even though the policy is correct now?
- Which command proves what is actually saved in IAM, as opposed to what you think you saved?

**Exam relevance (SAP-C03):** verify the effective permission with `get-role-policy`, not from memory, before you debug further.

Paste the whole-bucket listing after your clean session.

---

**You** (24 Nov 2026, 1:34 pm)

PS C:\Users\asgha\Desktop\AWS> aws s3 ls s3://lab3-session-logs-akash/ --recursive
>> 
2026-11-24 13:34:06        139 sessions/akash-asjsldlsnazklc953zz84dl2a4.log
2026-11-24 13:34:38        374 sessions/akash-der7q7ysp9ia792fol52naz854.log
PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:34 pm)

## Transcripts are landing in the new bucket

Two real keys are listed:
```
sessions/akash-asjsldlsnazklc953zz84dl2a4.log
sessions/akash-der7q7ysp9ia792fol52naz854.log
```
This ticks the "transcript appears in the S3 log bucket" item. The whole chain works: the agent validates encryption, the session runs, and the transcript uploads on exit using the instance role.

### Step 1: read one (use the real key, copied from above)
```
aws s3 cp s3://lab3-session-logs-akash/sessions/akash-der7q7ysp9ia792fol52naz854.log .\session-log.txt
type .\session-log.txt
```
- The second file is bigger (374 bytes), so it likely holds your commands.
- Check that you can see what was typed. That is the auditors' record of who did what, with the session ID tying back to `user/akash` in CloudTrail.
- The files are small because they only hold a few commands. Cost is effectively $0.

### Step 2: confirm the bucket settings (checklist item)
```
aws s3api get-public-access-block --bucket lab3-session-logs-akash
aws s3api get-bucket-encryption --bucket lab3-session-logs-akash
```
Block Public Access should show all four `true`, and encryption should show `AES256`.

### Step 3: remaining checklist items
Inside a session:
- `curl -m 5 https://www.google.com` should time out (no internet path).
- `echo test > /tmp/t.txt` then `aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt` should succeed. This proves the S3 gateway endpoint.

From your laptop:
- `aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[].IpPermissions'` should return `[]` (use your real SG id).
- `aws ec2 describe-instances` with the tag filter should show `PublicIpAddress` as null.
- `aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[].[ServiceName,VpcEndpointType,State]'` should show S3 as Gateway and the three others as Interface.

### Step 4: replacement test
Terminate the instance, launch a new one with the same role, subnet and SG, and time how long until `aws ssm describe-instance-information` shows `Online`. Target is under 5 minutes, with no changes.

### Then clean up
1. Delete the three **interface endpoints** first (they bill ~$0.033/hr).
2. Terminate the instance, then delete the SGs, route table, subnet and VPC.
3. Empty and delete both buckets, then delete the role, instance profile, and any test IAM user and group.
4. Run the clean-delete checks, including `aws resourcegroupstaggingapi get-resources --region ap-south-1 --tag-filters Key=Project,Values=aws-practice`.

### Cost
You are about 6 hours in, so the endpoints have cost roughly $0.20, well under the USD 1 cap. Don't leave them overnight (~$0.80).

### Self-check
- What do the session ID in the file name and CloudTrail each tell an auditor?
- Why is the instance role able to write these files but not list them?

**Exam relevance (SAP-C03):** session transcripts (what was typed) plus CloudTrail (who started the session) together answer "who did what". Add S3 Object Lock or versioning if auditors need tamper resistance.

Paste what the transcript shows, and your curl and gateway-test results.

---

**You** (24 Nov 2026, 1:35 pm)

PS C:\Users\asgha\Desktop\AWS> aws s3 ls s3://lab3-session-logs-akash/ --recursive
>> 
2026-11-24 13:34:06        139 sessions/akash-asjsldlsnazklc953zz84dl2a4.log
2026-11-24 13:34:38        374 sessions/akash-der7q7ysp9ia792fol52naz854.log
PS C:\Users\asgha\Desktop\AWS> aws s3 cp s3://lab3-session-logs-akash/sessions/akash-der7q7ysp9ia792fol52naz854.log .\session-log.txt
>> type .\session-log.txt
>> 
download: s3://lab3-session-logs-akash/sessions/akash-der7q7ysp9ia792fol52naz854.log to .\session-log.txt
Script started on 2026-11-24 08:04:37+00:00 [<not executed on terminal>]
sh-5.2$ whoami
ssm-user
sh-5.2$ uptime
 08:04:28 up 50 min,  0 users,  load average: 0.00, 0.00, 0.00
sh-5.2$ ls /
bin  boot  devetc  home  liblib64  local  media  mnt  opt  proc  root  runsbin  srv  systmp  usr  var
sh-5.2$ exit
exit

Script done on 2026-11-24 08:04:37+00:00 [COMMAND_EXIT_CODE="0"]
PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:35 pm)

## The transcript works: this is the auditors' record

Your file shows exactly what was typed (`whoami`, `uptime`, `ls /`, `exit`), the start and end times, and the exit code. Two details worth understanding:

- **`whoami` returned `ssm-user`.** Every Session Manager shell runs as this shared OS account. The transcript alone doesn't say *which human* typed the commands. The file name holds the session ID (`akash-der7q7...`), and the session ID starts with the IAM user name. CloudTrail's `StartSession` event ties the same ID to `user/akash`. Together they answer "who did what".
- **Timestamps differ.** The S3 listing shows 13:34 (your laptop's IST) and the file says 08:04 (UTC). Same moment, 5h30m apart. Not an error.

The odd spacing in `ls /` output (`devetc`, `liblib64`) is just terminal capture of columns. Ignore it.

### Prove the CloudTrail link (optional, 2 minutes)
```
aws cloudtrail lookup-events --region ap-south-1 --lookup-attributes AttributeKey=EventName,AttributeValue=StartSession --max-items 3 --query 'Events[].[EventTime,Username]'
```
Event history only shows recent management events, so it should show your sessions.

### Next checklist items (inside a session)
1. No internet path (should time out after 5 seconds):
   ```
   curl -m 5 https://www.google.com
   ```
2. S3 gateway endpoint (should succeed):
   ```
   echo test > /tmp/t.txt
   aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt
   ```
   Delete that file afterwards from your laptop, so it doesn't sit among the transcripts.

### From your laptop
```
aws s3api get-public-access-block --bucket lab3-session-logs-akash
aws s3api get-bucket-encryption --bucket lab3-session-logs-akash
aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[ServiceName,VpcEndpointType,State]'
```
Also run the `describe-instances` and `describe-security-groups` checks from the checklist (use your real instance and SG IDs).

### Then
1. Terminate the instance, launch a replacement with the same role, subnet and SG, and time it to **Online** (target under 5 minutes).
2. Delete the three interface endpoints right after.
3. Clean-delete: VPC pieces, both buckets (empty first), role and instance profile, test user and group. Then run the tag-based `resourcegroupstaggingapi` check.

### Cost
You're roughly 6 hours in. The three interface endpoints cost about $0.033/hr, so about $0.20 so far, under the USD 1 cap. Overnight would add about $0.80, so don't leave them running.

### Self-check
- Why does the transcript show `ssm-user`, and what two sources together identify the human?
- Why must the gateway-test file be deleted afterwards?

**Exam relevance (SAP-C03):** Session Manager audit = CloudTrail (who started the session) + S3 or CloudWatch session logs (what was run). For stricter per-user identity, you can enable Run As or restrict the vendor with a custom session document.

Paste your curl and gateway-test results.

---

**You** (24 Nov 2026, 1:36 pm)

sh-5.2$ curl -m 5 https://www.google.com

curl: (28) Connection timed out after 5001 milliseconds
sh-5.2$ 
sh-5.2$ echo test > /tmp/t.txt
sh-5.2$ aws s3 cp /tmp/t.txt s3://lab3-session-logs-akash/sessions/gateway-test.txt

upload: ../../tmp/t.txt to s3://lab3-session-logs-akash/sessions/gateway-test.txt
sh-5.2$ 
sh-5.2$ 




PS C:\Users\asgha\Desktop\AWS> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
>> 

aws: [ERROR]: SessionManagerPlugin is not found. Please refer to SessionManager Documentation here: http://docs.aws.amazon.com/console/systems-manager/session-manager-plugin-not-found
PS C:\Users\asgha\Desktop\AWS> $env:Path += ";C:\Program Files\Amazon\SessionManagerPlugin\bin"                                    
>> session-manager-plugin                                                      
>> 

The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.

PS C:\Users\asgha\Desktop\AWS> aws ssm start-session --target i-034eaffd299e9c196 --region ap-south-1
>>                       
   
Starting session with SessionId: akash-der7q7ysp9ia792fol52naz854
sh-5.2$ whoami
ssm-user
sh-5.2$ uptime
 08:04:28 up 50 min,  0 users,  load average: 0.00, 0.00, 0.00
sh-5.2$ ls /
bin  boot  dev  etc  home  lib  lib64  local  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
sh-5.2$ exit
exit


Exiting session with sessionId: akash-der7q7ysp9ia792fol52naz854.

PS C:\Users\asgha\Desktop\AWS> aws s3 ls s3://lab3-session-logs-akash/ --recursive
>> 
2026-11-24 13:34:06        139 sessions/akash-asjsldlsnazklc953zz84dl2a4.log
2026-11-24 13:34:38        374 sessions/akash-der7q7ysp9ia792fol52naz854.log
PS C:\Users\asgha\Desktop\AWS> aws s3 cp s3://lab3-session-logs-akash/sessions/akash-der7q7ysp9ia792fol52naz854.log .\session-log.txt
>> type .\session-log.txt
>> 
download: s3://lab3-session-logs-akash/sessions/akash-der7q7ysp9ia792fol52naz854.log to .\session-log.txt
Script started on 2026-11-24 08:04:37+00:00 [<not executed on terminal>]
sh-5.2$ whoami
ssm-user
sh-5.2$ uptime
 08:04:28 up 50 min,  0 users,  load average: 0.00, 0.00, 0.00
sh-5.2$ ls /
bin  boot  devetc  home  liblib64  local  media  mnt  opt  proc  root  runsbin  srv  systmp  usr  var
sh-5.2$ exit
exit

Script done on 2026-11-24 08:04:37+00:00 [COMMAND_EXIT_CODE="0"]
PS C:\Users\asgha\Desktop\AWS> aws cloudtrail lookup-events --region ap-south-1 --lookup-attributes AttributeKey=EventName,AttributeValue=StartSession --max-items 3 --query 'Events[].[EventTime,Username]'
>> 
[                                                                                                                                                            
    [
        "2026-11-24T13:31:29+05:30",
        "akash"
    ],
    [
        "2026-11-24T13:28:02+05:30",
        "akash"
    ],
    [
        "2026-11-24T13:16:07+05:30",
        "akash"
    ]
]

PS C:\Users\asgha\Desktop\AWS> aws s3api get-public-access-block --bucket lab3-session-logs-akash
>> aws s3api get-bucket-encryption --bucket lab3-session-logs-akash
>> aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[ServiceName,VpcEndpointType,State]'
>> 
{                                                                                                                                                            
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}

{                                                                                                                                                            
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true,
                "BlockedEncryptionTypes": {
                    "EncryptionType": [
                        "SSE-C"
                    ]
                }
            }
        ]
    }
}

[                                                                                                                                                            
    [
        "com.amazonaws.ap-south-1.s3",
        "Gateway",
        "available"
    ],
    [
        "com.amazonaws.ap-south-1.ssm",
        "Interface",
        "available"
    ],
    [
        "com.amazonaws.ap-south-1.ssmmessages",
        "Interface",
        "available"
    ],
    [
        "com.amazonaws.ap-south-1.ec2messages",
        "Interface",
        "available"
    ]
]

PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:36 pm)

## Strong results: most of the checklist is now proven

| Check | Result | Proves |
|---|---|---|
| `curl -m 5 google.com` | timed out | no internet path |
| `aws s3 cp` from the server | upload succeeded | S3 reached privately via the gateway endpoint |
| Public Access Block | all four `true` | bucket is not public |
| Default encryption | `AES256` | SSE-S3 on |
| `describe-vpc-endpoints` | S3 Gateway, ssm/ssmmessages/ec2messages Interface, all `available` | endpoint types are correct |
| CloudTrail `StartSession` | shows `akash` | "who started the session" |

### One thing to tidy up now
The `gateway-test.txt` file is sitting among the transcripts. Delete it from your laptop:
```
aws s3 rm s3://lab3-session-logs-akash/sessions/gateway-test.txt
```
Otherwise an auditor will find a non-transcript file in the evidence folder.

### Not yet ticked
- **`ec2-sg` inbound is `[]`:** run `aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[].IpPermissions'`. Get the real id with `aws ec2 describe-instances --region ap-south-1 --filters Name=tag:Project,Values=aws-practice --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,IamInstanceProfile.Arn,SubnetId,SecurityGroups[0].GroupId]'`. The same command also proves `PublicIpAddress` is null and the instance profile is attached.
- **Route table has no `0.0.0.0/0`:** `aws ec2 describe-route-tables --region ap-south-1 --filters Name=tag:Project,Values=aws-practice --query 'RouteTables[].Routes'` (the S3 gateway endpoint shows up as a prefix-list route, which is expected).
- **Replacement test (resilience):** terminate the instance, launch a new one with the same role, subnet and SG, and time it to **Online** in `describe-instance-information` (target under 5 minutes, no other changes). Keep the same settings, since this is what the customer's 30-minute RTO depends on.

### Then clean up (endpoints first)
1. Delete the **three interface endpoints** right after the replacement test.
2. Terminate the instance, then delete the SGs, route table, subnet and VPC.
3. Empty and delete both buckets, then delete the role, instance profile, test user and group.
4. Run the clean-delete checks, including `aws resourcegroupstaggingapi get-resources --region ap-south-1 --tag-filters Key=Project,Values=aws-practice` and `aws ec2 describe-addresses`.

### Cost
You're roughly 6 hours in, so the three interface endpoints have cost about $0.20 in total, under the USD 1 cap. Don't leave them overnight (about $0.80 extra).

### Self-check
- Which two sources together say who typed what, given that `whoami` shows `ssm-user`?
- Why did a successful S3 upload prove the gateway endpoint, while the curl timeout proved there is no internet path?

**Exam relevance (SAP-C03):** know that Session Manager needs `ssm`, `ssmmessages` and `ec2messages` interface endpoints in a no-NAT design, while S3 uses a free gateway endpoint. That's the cost trade-off the customer asked about.

Paste the three describe outputs (instance, SG, routes) and the replacement time.

---

**You** (24 Nov 2026, 1:37 pm)

let's clean up list down each and every reosuce give me command from command I'll clean up

---

**Tutor** (24 Nov 2026, 1:38 pm)

## Cleanup, in dependency order

Run in PowerShell. Replace `<...>` placeholders with real IDs from the discovery commands. Your user `akash` and the default VPC stay untouched.

Optional: the replacement test, SG check and route check are still unticked. Each takes about 2 minutes, and the endpoints bill (~$0.033/hr) while you do them. If you skip them, you can run them in the Terraform rebuild.

### 0. Discover your IDs
```
$R="ap-south-1"
aws ec2 describe-vpcs --region $R --filters Name=tag:Project,Values=aws-practice --query 'Vpcs[].[VpcId,CidrBlock]'
aws ec2 describe-instances --region $R --filters Name=tag:Project,Values=aws-practice Name=instance-state-name,Values=pending,running,stopped --query 'Reservations[].Instances[].[InstanceId,VpcId]'
aws ec2 describe-vpc-endpoints --region $R --query 'VpcEndpoints[].[VpcEndpointId,ServiceName]'
aws ec2 describe-subnets --region $R --filters Name=tag:Project,Values=aws-practice --query 'Subnets[].[SubnetId,VpcId]'
aws ec2 describe-route-tables --region $R --filters Name=tag:Project,Values=aws-practice --query 'RouteTables[].RouteTableId'
aws ec2 describe-security-groups --region $R --filters Name=vpc-id,Values=<vpc-id> --query 'SecurityGroups[].[GroupId,GroupName]'
```

### 1. Interface and gateway endpoints (this stops the billing)
```
aws ec2 delete-vpc-endpoints --region $R --vpc-endpoint-ids <ssm-id> <ssmmessages-id> <ec2messages-id> <s3-gateway-id>
aws ec2 describe-vpc-endpoints --region $R --query 'VpcEndpoints[].[VpcEndpointId,State]'
```
Repeat the last command until it returns `[]` (1-3 min). Their network interfaces must disappear before the security groups can be deleted.

### 2. Instance
```
aws ec2 terminate-instances --region $R --instance-ids <instance-id>
aws ec2 wait instance-terminated --region $R --instance-ids <instance-id>
```
The 8 GB root volume goes with it (delete-on-termination is the default).

### 3. Network, in this order
```
aws ec2 delete-security-group --region $R --group-id <endpoint-sg-id>
aws ec2 delete-security-group --region $R --group-id <ec2-sg-id>
aws ec2 delete-subnet --region $R --subnet-id <subnet-id>
aws ec2 delete-route-table --region $R --route-table-id <your-route-table-id>
aws ec2 delete-vpc --region $R --vpc-id <vpc-id>
```
- Delete the route table you created, not the VPC's main route table (that one goes with the VPC).
- If a security group says `DependencyViolation`, the endpoints or instance are not fully gone yet. Wait and retry.

### 4. CloudTrail (only if you created a trail)
```
aws cloudtrail describe-trails --region $R --query 'trailList[].Name'
aws cloudtrail delete-trail --region $R --name <trail-name>
```

### 5. S3 buckets (empty first, then delete)
```
aws s3 rm s3://lab3-session-logs-akash --recursive
aws s3api delete-bucket --bucket lab3-session-logs-akash --region $R
aws s3 rm s3://lab3-cloudtrail-bucket-akash --recursive
aws s3api delete-bucket --bucket lab3-cloudtrail-bucket-akash --region $R
```
If you enabled versioning, `delete-bucket` will say `BucketNotEmpty`. Then delete the versions in the Console (Bucket → Empty), or tell me and I'll give the CLI.

### 6. IAM: instance role and profile
```
aws iam list-instance-profiles-for-role --role-name lab3-ec2-ssm --query 'InstanceProfiles[].InstanceProfileName'
aws iam remove-role-from-instance-profile --instance-profile-name <profile-name> --role-name lab3-ec2-ssm
aws iam delete-instance-profile --instance-profile-name <profile-name>
aws iam detach-role-policy --role-name lab3-ec2-ssm --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam delete-role-policy --role-name lab3-ec2-ssm --policy-name lab3-inline-s3
aws iam delete-role --role-name lab3-ec2-ssm
```

### 7. IAM: admin group and test user (skip if you never created them)
```
aws iam list-groups --query 'Groups[].GroupName'
aws iam list-attached-group-policies --group-name kovai-admins
aws iam list-group-policies --group-name kovai-admins
```
Then remove what these show:
```
aws iam detach-group-policy --group-name kovai-admins --policy-arn <arn>
aws iam delete-group-policy --group-name kovai-admins --policy-name <name>
aws iam remove-user-from-group --group-name kovai-admins --user-name <test-user>
aws iam delete-group --group-name kovai-admins
```
For the test user, find and delete what it has:
```
aws iam list-mfa-devices --user-name <test-user>
aws iam list-access-keys --user-name <test-user>
```
```
aws iam deactivate-mfa-device --user-name <test-user> --serial-number <arn>
aws iam delete-virtual-mfa-device --serial-number <arn>
aws iam delete-login-profile --user-name <test-user>
aws iam delete-user --user-name <test-user>
```
Do not delete `user/akash`. It is your own login.

### 8. Leftovers to check
```
aws logs describe-log-groups --region $R --query 'logGroups[].logGroupName'
aws ssm get-document --name SSM-SessionManagerRunShell --region $R --query Name
aws ec2 describe-volumes --region $R --query 'Volumes[].[VolumeId,State]'
aws ec2 describe-addresses --region $R
```
- Delete any log group you created for this lab: `aws logs delete-log-group --region $R --log-group-name <name>`.
- The `SSM-SessionManagerRunShell` document holds your Session Manager preferences and is free. Reset it with `aws ssm delete-document --name SSM-SessionManagerRunShell --region $R`. Otherwise it keeps pointing at a deleted bucket and will break the next session.
- No volumes or Elastic IPs should remain.

### 9. Final verification (the checklist item)
```
aws resourcegroupstaggingapi get-resources --region ap-south-1 --tag-filters Key=Project,Values=aws-practice
aws ec2 describe-vpc-endpoints --region ap-south-1
aws ec2 describe-instances --region ap-south-1 --filters Name=instance-state-name,Values=pending,running,stopped
aws ec2 describe-addresses --region ap-south-1
aws s3 ls
```
- Everything should be empty. A terminated instance may linger in listings for about an hour. That is fine.
- IAM resources are global, so the tag check may not show them. The steps above cover those.

### Cost
Total for the exercise is about $0.20-0.25, under the USD 1 cap. Once the endpoints are deleted, billing stops. Nothing here costs money overnight.

### Self-check
- Why do endpoints have to be deleted before security groups, and the instance before the subnet?
- Why will the next session fail if you delete the buckets but not the Session Manager preferences?

**Exam relevance (SAP-C03):** teardown order follows dependencies (ENIs → SGs → subnets → VPC). Terraform works this graph out for you, which is why the rebuild is worth the hour.

Paste the step 9 outputs and we'll confirm it's clean, then plan the Terraform rebuild in small pieces.

---

**You** (24 Nov 2026, 1:38 pm)

don't give me that replcae thing you can give me read read commands I'll paste output and then you can give me delete ones

---

**Tutor** (24 Nov 2026, 1:38 pm)

## Read-only discovery (nothing here deletes anything)

Paste this whole block into PowerShell and send me the full output. There are no placeholders.

```
$R="ap-south-1"
"--- VPCs"
aws ec2 describe-vpcs --region $R --query 'Vpcs[].[VpcId,CidrBlock,IsDefault,Tags[?Key==`Project`]|[0].Value]' --output text
"--- Instances (not terminated)"
aws ec2 describe-instances --region $R --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].[InstanceId,State.Name,VpcId,SubnetId]' --output text
"--- VPC endpoints"
aws ec2 describe-vpc-endpoints --region $R --query 'VpcEndpoints[].[VpcEndpointId,ServiceName,VpcEndpointType,VpcId,State]' --output text
"--- Subnets"
aws ec2 describe-subnets --region $R --query 'Subnets[].[SubnetId,VpcId,CidrBlock,DefaultForAz]' --output text
"--- Route tables"
aws ec2 describe-route-tables --region $R --query 'RouteTables[].[RouteTableId,VpcId,Associations[0].Main]' --output text
"--- Security groups"
aws ec2 describe-security-groups --region $R --query 'SecurityGroups[].[GroupId,GroupName,VpcId]' --output text
"--- Internet gateways, NAT, EIPs, volumes"
aws ec2 describe-internet-gateways --region $R --query 'InternetGateways[].[InternetGatewayId,Attachments[0].VpcId]' --output text
aws ec2 describe-nat-gateways --region $R --filter Name=state,Values=available,pending --query 'NatGateways[].NatGatewayId' --output text
aws ec2 describe-addresses --region $R --query 'Addresses[].AllocationId' --output text
aws ec2 describe-volumes --region $R --query 'Volumes[].[VolumeId,State]' --output text
"--- CloudTrail, log groups, SSM doc"
aws cloudtrail describe-trails --region $R --query 'trailList[].[Name,S3BucketName]' --output text
aws logs describe-log-groups --region $R --query 'logGroups[].logGroupName' --output text
aws ssm describe-document --name SSM-SessionManagerRunShell --region $R --query 'Document.Name' --output text
"--- S3"
aws s3 ls
aws s3api get-bucket-versioning --bucket lab3-session-logs-akash
aws s3api get-bucket-versioning --bucket lab3-cloudtrail-bucket-akash
"--- IAM"
aws iam list-roles --query 'Roles[?starts_with(RoleName,`lab3`)].RoleName' --output text
aws iam list-instance-profiles --query 'InstanceProfiles[].[InstanceProfileName,Roles[0].RoleName]' --output text
aws iam list-groups --query 'Groups[].GroupName' --output text
aws iam list-users --query 'Users[].UserName' --output text
"--- Tag check"
aws resourcegroupstaggingapi get-resources --region $R --tag-filters Key=Project,Values=aws-practice --query 'ResourceTagMappingList[].ResourceARN' --output text
```

### How I'll use the output
- I'll separate the lab VPC from your default VPC (`IsDefault True`), so we never touch the default one.
- I'll order the deletes by dependency: endpoints, instance, security groups, subnet, route table, VPC, then buckets and IAM.
- I'll give you exact delete commands with your real IDs filled in.
- If any resource looks like something you didn't create for this lab, I'll flag it instead of deleting it.

### Cost
The three interface endpoints are still billing (about $0.033/hr), so run this soon. Total so far is roughly $0.20-0.25, well under the USD 1 cap.

Paste the full output and I'll reply with the delete commands.

---

**You** (24 Nov 2026, 1:39 pm)

PS C:\Users\asgha\Desktop\AWS> $R="ap-south-1"
>> "--- VPCs"
>> aws ec2 describe-vpcs --region $R --query 'Vpcs[].[VpcId,CidrBlock,IsDefault,Tags[?Key==`Project`]|[0].Value]' --output text
>> "--- Instances (not terminated)"
>> aws ec2 describe-instances --region $R --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].[InstanceId,State.Name,VpcId,SubnetId]' --output text
>> "--- VPC endpoints"
>> aws ec2 describe-vpc-endpoints --region $R --query 'VpcEndpoints[].[VpcEndpointId,ServiceName,VpcEndpointType,VpcId,State]' --output text
>> "--- Subnets"
>> aws ec2 describe-subnets --region $R --query 'Subnets[].[SubnetId,VpcId,CidrBlock,DefaultForAz]' --output text
>> "--- Route tables"
>> aws ec2 describe-route-tables --region $R --query 'RouteTables[].[RouteTableId,VpcId,Associations[0].Main]' --output text
>> "--- Security groups"
>> aws ec2 describe-security-groups --region $R --query 'SecurityGroups[].[GroupId,GroupName,VpcId]' --output text
>> "--- Internet gateways, NAT, EIPs, volumes"
>> aws ec2 describe-internet-gateways --region $R --query 'InternetGateways[].[InternetGatewayId,Attachments[0].VpcId]' --output text
>> aws ec2 describe-nat-gateways --region $R --filter Name=state,Values=available,pending --query 'NatGateways[].NatGatewayId' --output text
>> aws ec2 describe-addresses --region $R --query 'Addresses[].AllocationId' --output text
>> aws ec2 describe-volumes --region $R --query 'Volumes[].[VolumeId,State]' --output text
>> "--- CloudTrail, log groups, SSM doc"
>> aws cloudtrail describe-trails --region $R --query 'trailList[].[Name,S3BucketName]' --output text
>> aws logs describe-log-groups --region $R --query 'logGroups[].logGroupName' --output text
>> aws ssm describe-document --name SSM-SessionManagerRunShell --region $R --query 'Document.Name' --output text
>> "--- S3"
>> aws s3 ls
>> aws s3api get-bucket-versioning --bucket lab3-session-logs-akash
>> aws s3api get-bucket-versioning --bucket lab3-cloudtrail-bucket-akash
>> "--- IAM"
>> aws iam list-roles --query 'Roles[?starts_with(RoleName,`lab3`)].RoleName' --output text
>> aws iam list-instance-profiles --query 'InstanceProfiles[].[InstanceProfileName,Roles[0].RoleName]' --output text
>> aws iam list-groups --query 'Groups[].GroupName' --output text
>> aws iam list-users --query 'Users[].UserName' --output text
>> "--- Tag check"
>> aws resourcegroupstaggingapi get-resources --region $R --tag-filters Key=Project,Values=aws-practice --query 'ResourceTagMappingList[].ResourceARN' --output text
>> 
--- VPCs
vpc-006d93adcf21ea3ad   10.0.0.0/16     False   aws-practice                                                                                                 
vpc-011c6227ea559561e   172.31.0.0/16   True    None

--- Instances (not terminated)
i-034eaffd299e9c196     running vpc-006d93adcf21ea3ad   subnet-07a45d18afa034156                                                                             

--- VPC endpoints
vpce-094a37e0c48dcb545  com.amazonaws.ap-south-1.s3     Gateway vpc-006d93adcf21ea3ad   available                                                            
vpce-01ec6dc06fec298e5  com.amazonaws.ap-south-1.ssm    Interface       vpc-006d93adcf21ea3ad   available
vpce-059714bff2e7e9817  com.amazonaws.ap-south-1.ssmmessages    Interface       vpc-006d93adcf21ea3ad   available
vpce-0dcad0778cfddbcbc  com.amazonaws.ap-south-1.ec2messages    Interface       vpc-006d93adcf21ea3ad   available

--- Subnets
subnet-021c32d1d55cae2b8        vpc-011c6227ea559561e   172.31.1.0/24   False                                                                                
subnet-0b9d261722eb31057        vpc-011c6227ea559561e   172.31.12.0/24  False
subnet-07a45d18afa034156        vpc-006d93adcf21ea3ad   10.0.128.0/20   False
subnet-0e34b2e776c0a1e4e        vpc-011c6227ea559561e   172.31.11.0/24  False
subnet-04d8903eba73380b2        vpc-011c6227ea559561e   172.31.2.0/24   False

--- Route tables
rtb-0cff68f616f46597a   vpc-006d93adcf21ea3ad   True                                                                                                         
rtb-0e326f0b2d0a3ec4f   vpc-011c6227ea559561e   True
rtb-07adb7966126c0b02   vpc-006d93adcf21ea3ad   False

--- Security groups
sg-0a1a2628ff71ef3c8    default vpc-006d93adcf21ea3ad                                                                                                        
sg-040ab77911d99ca3f    endpoint-sg     vpc-006d93adcf21ea3ad
sg-08cd8c42fc642459c    ec2-sg  vpc-006d93adcf21ea3ad
sg-018b4795d18994a8f    default vpc-011c6227ea559561e

--- Internet gateways, NAT, EIPs, volumes
igw-07239733fe299a2f0   vpc-011c6227ea559561e                                                                                                                

vol-0dcd4d247686a5daf   in-use                                                                                                                               

--- CloudTrail, log groups, SSM doc
SSM-SessionManagerRunShell                                                                                                                                   

--- S3
2026-11-21 20:09:11 lab3-bucket-akash
2026-11-24 11:40:09 lab3-cloudtrail-bucket-akash
2026-11-24 13:20:09 lab3-session-logs-akash
--- IAM
lab3-ec2-ssm                                                                                                                                                 

lab3-ec2-ssm    lab3-ec2-ssm                                                                                                                                 

admin   kovai-admins                                                                                                                                         

akash   lab3-admin                                                                                                                                           

--- Tag check
arn:aws:ec2:ap-south-1:908402822288:subnet/subnet-07a45d18afa034156     arn:aws:ec2:ap-south-1:908402822288:vpc/vpc-006d93adcf21ea3ad   arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-094a37e0c48dcb545 arn:aws:s3:::lab3-bucket-akash  arn:aws:ec2:ap-south-1:908402822288:security-group/sg-040ab77911d99ca3f arn:aws:ec2:ap-south-1:908402822288:instance/i-034eaffd299e9c196        arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-01ec6dc06fec298e5 arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-0dcad0778cfddbcbc arn:aws:ec2:ap-south-1:908402822288:route-table/rtb-07adb7966126c0b02   arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-059714bff2e7e9817

PS C:\Users\asgha\Desktop\AWS> 


delete everything which can cost me

---

**Tutor** (24 Nov 2026, 1:39 pm)

## Step 1: Delete the billing resources (copy-paste, real IDs)

Only the three interface endpoints and the instance (plus its 8 GB volume) cost money. The S3 gateway endpoint, VPC, subnet, security groups, IAM and buckets are free or near $0. Your default VPC (`vpc-011c...`) is untouched.

```
$R="ap-south-1"
aws ec2 delete-vpc-endpoints --region $R --vpc-endpoint-ids vpce-01ec6dc06fec298e5 vpce-059714bff2e7e9817 vpce-0dcad0778cfddbcbc
```
This stops the ~$0.033/hr charge. The commands below don't need these endpoints, so run them straight away.

## Step 2: Capture the unticked evidence (read-only, 30 seconds)

These three checklist items are still unproven. Run them before the instance is gone:
```
aws ec2 describe-instances --region $R --instance-ids i-034eaffd299e9c196 --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,IamInstanceProfile.Arn,SubnetId]' --output text
aws ec2 describe-security-groups --region $R --group-ids sg-08cd8c42fc642459c --query 'SecurityGroups[].IpPermissions'
aws ec2 describe-route-tables --region $R --route-table-ids rtb-07adb7966126c0b02 --query 'RouteTables[].Routes'
```
Expect `None` for the public IP, `[]` for the inbound rules, and only a `local` route plus the S3 prefix-list route. Paste them if you want me to confirm.

## Step 3: Terminate the instance

```
aws ec2 terminate-instances --region $R --instance-ids i-034eaffd299e9c196
aws ec2 wait instance-terminated --region $R --instance-ids i-034eaffd299e9c196
```

## Step 4: Verify billing has stopped (read-only)

```
aws ec2 describe-vpc-endpoints --region $R --query 'VpcEndpoints[].[VpcEndpointId,VpcEndpointType,State]' --output text
aws ec2 describe-instances --region $R --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text
aws ec2 describe-volumes --region $R --query 'Volumes[].[VolumeId,State]' --output text
```
- The endpoint list should show only the S3 Gateway (free). The interface ones may show `deleting` for a minute or two.
- No instances and no volumes should remain.

## What I'm deliberately not deleting yet
- **`lab3-bucket-akash`** is tagged `Project=aws-practice` and was created on Nov 21. It looks like it's from an earlier level, and it's ~$0. Tell me if you want it removed.
- **IAM user `admin`** (in `kovai-admins`) is free. Tell me if it's your Level 3 test user.
- **Your user `akash`** stays. It's your login.
- **SSM preferences document** is free. It still points at the session-log bucket, so it needs resetting when we delete the buckets.

After you paste the Step 4 output, I'll give the remaining free tidy-up commands (SGs, subnet, route table, VPC, buckets, IAM) in dependency order.

## Cost
Total for the exercise is about $0.25-0.30, under the USD 1 cap. After Step 1 and Step 3 nothing bills overnight.

**Self-check:** Why is the S3 gateway endpoint free while the interface endpoints bill hourly per AZ?

**Exam relevance (SAP-C03):** gateway endpoints (S3, DynamoDB) are free route-table targets. Interface endpoints are ENIs billed hourly plus per GB.

---

**You** (24 Nov 2026, 1:42 pm)

PS C:\Users\asgha\Desktop\AWS> $R="ap-south-1"
>> aws ec2 delete-vpc-endpoints --region $R --vpc-endpoint-ids vpce-01ec6dc06fec298e5 vpce-059714bff2e7e9817 vpce-0dcad0778cfddbcbc
>> 
{                                                                                                                                                            
    "Unsuccessful": []
}

PS C:\Users\asgha\Desktop\AWS> aws ec2 describe-instances --region $R --instance-ids i-034eaffd299e9c196 --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,IamInstanceProfile.Arn,SubnetId]' --output text
>> aws ec2 describe-security-groups --region $R --group-ids sg-08cd8c42fc642459c --query 'SecurityGroups[].IpPermissions'
>> aws ec2 describe-route-tables --region $R --route-table-ids rtb-07adb7966126c0b02 --query 'RouteTables[].Routes'
>> 
i-034eaffd299e9c196     None    arn:aws:iam::908402822288:instance-profile/lab3-ec2-ssm subnet-07a45d18afa034156                                             

[                                                                                                                                                            
    []
]

[                                                                                                                                                            
    [
        {
            "DestinationCidrBlock": "10.0.0.0/16",
            "GatewayId": "local",
            "Origin": "CreateRouteTable",
            "State": "active"
        },
        {
            "DestinationPrefixListId": "pl-78a54011",
            "GatewayId": "vpce-094a37e0c48dcb545",
            "Origin": "CreateRoute",
            "State": "active"
        }
    ]
]

PS C:\Users\asgha\Desktop\AWS> aws ec2 terminate-instances --region $R --instance-ids i-034eaffd299e9c196
>> aws ec2 wait instance-terminated --region $R --instance-ids i-034eaffd299e9c196
>> 
{                                                                                                                                                            
    "TerminatingInstances": [
        {
            "InstanceId": "i-034eaffd299e9c196",
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}

PS C:\Users\asgha\Desktop\AWS> aws ec2 describe-vpc-endpoints --region $R --query 'VpcEndpoints[].[VpcEndpointId,VpcEndpointType,State]' --output text
>> aws ec2 describe-instances --region $R --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text
>> aws ec2 describe-volumes --region $R --query 'Volumes[].[VolumeId,State]' --output text
>> 
vpce-094a37e0c48dcb545  Gateway available                                                                                                                    
vpce-059714bff2e7e9817  Interface       deleting
vpce-0dcad0778cfddbcbc  Interface       deleting

PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:42 pm)

## Billing is stopped

- The instance is terminated (no instances, no volumes listed).
- Two interface endpoints show `deleting`, and `vpce-01ec...` (ssm) is already gone. Once they disappear, nothing on this account bills overnight.
- **Your evidence is captured:**
  - `PublicIpAddress` = None, instance profile `lab3-ec2-ssm` attached
  - `ec2-sg` inbound = `[]`
  - Route table = `local` + S3 prefix-list route only, no `0.0.0.0/0`

That ticks the three remaining checklist items except the replacement test. You skipped that one, so do it in the Terraform rebuild (`aws_instance` with the same role, subnet and SG, then time it to Online).

## Step 5: Wait for the endpoints to finish deleting (read-only)

Run until it shows only the S3 Gateway:
```
aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[VpcEndpointId,VpcEndpointType,State]' --output text
```
The security groups can't be deleted while endpoint network interfaces still exist, so wait for this.

## Step 6: Delete the network (free, but tidy)

Run after Step 5 is clear:
```
$R="ap-south-1"
aws ec2 delete-vpc-endpoints --region $R --vpc-endpoint-ids vpce-094a37e0c48dcb545
aws ec2 delete-security-group --region $R --group-id sg-040ab77911d99ca3f
aws ec2 delete-security-group --region $R --group-id sg-08cd8c42fc642459c
aws ec2 delete-subnet --region $R --subnet-id subnet-07a45d18afa034156
aws ec2 delete-route-table --region $R --route-table-id rtb-07adb7966126c0b02
aws ec2 delete-vpc --region $R --vpc-id vpc-006d93adcf21ea3ad
```
- The VPC's `default` SG (`sg-0a1a...`) and main route table (`rtb-0cff...`) go with the VPC automatically.
- If a command says `DependencyViolation`, wait a minute and retry it.
- Your default VPC `vpc-011c...` is not touched.

## Step 7: Buckets and Session Manager preferences

Do these after the network:
```
aws s3 rm s3://lab3-session-logs-akash --recursive
aws s3api delete-bucket --bucket lab3-session-logs-akash --region $R
aws s3 rm s3://lab3-cloudtrail-bucket-akash --recursive
aws s3api delete-bucket --bucket lab3-cloudtrail-bucket-akash --region $R
aws ssm delete-document --name SSM-SessionManagerRunShell --region $R
```
- `lab3-bucket-akash` (Nov 21, tagged `Project=aws-practice`) looks like an earlier level's. Tell me if you want it gone and I'll give the commands.
- No CloudTrail trail exists, so the CloudTrail bucket is empty or has little in it.

## Step 8: IAM (free)

Read-only first, so I can fill in exact names:
```
aws iam list-attached-role-policies --role-name lab3-ec2-ssm --query 'AttachedPolicies[].PolicyArn' --output text
aws iam list-attached-group-policies --group-name kovai-admins --query 'AttachedPolicies[].PolicyArn' --output text
aws iam list-group-policies --group-name kovai-admins --output text
aws iam list-mfa-devices --user-name admin --query 'MFADevices[].SerialNumber' --output text
```
Confirm that `admin` is your Level 3 test user and `lab3-admin` is the group your own user `akash` belongs to. I won't delete either until you say so, since removing the wrong one could lock you out.

## Cost
Total so far is roughly $0.25-0.30, under the USD 1 cap. After the endpoints finish deleting, nothing bills.

**Self-check:** Why can't a security group be deleted while an endpoint is still `deleting`?

Paste the Step 5 output (and the Step 8 reads) and I'll confirm.

---

**You** (24 Nov 2026, 1:42 pm)

PS C:\Users\asgha\Desktop\AWS> aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].[VpcEndpointId,VpcEndpointType,State]' --output text
>> 
vpce-094a37e0c48dcb545  Gateway available                                                                                                                    

PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:42 pm)

## Interface endpoints are gone, so billing has stopped

Only the free S3 Gateway endpoint remains. Nothing on this account bills overnight now. Total spend is roughly $0.25-0.30, under the USD 1 cap.

## Step 6: Delete the network (free, but tidy)

Run these in order. If one says `DependencyViolation`, wait a minute and retry that one.

```
$R="ap-south-1"
aws ec2 delete-vpc-endpoints --region $R --vpc-endpoint-ids vpce-094a37e0c48dcb545
aws ec2 delete-security-group --region $R --group-id sg-040ab77911d99ca3f
aws ec2 delete-security-group --region $R --group-id sg-08cd8c42fc642459c
aws ec2 delete-subnet --region $R --subnet-id subnet-07a45d18afa034156
aws ec2 delete-route-table --region $R --route-table-id rtb-07adb7966126c0b02
aws ec2 delete-vpc --region $R --vpc-id vpc-006d93adcf21ea3ad
```

- The gateway endpoint goes first because it is attached to the route table.
- The VPC's own `default` SG (`sg-0a1a...`) and main route table (`rtb-0cff...`) are removed with the VPC.
- Your default VPC `vpc-011c...` is not touched.

## Step 7: Session Manager preferences and the two lab buckets

```
aws ssm delete-document --name SSM-SessionManagerRunShell --region $R
aws s3 rm s3://lab3-session-logs-akash --recursive
aws s3api delete-bucket --bucket lab3-session-logs-akash --region $R
aws s3 rm s3://lab3-cloudtrail-bucket-akash --recursive
aws s3api delete-bucket --bucket lab3-cloudtrail-bucket-akash --region $R
```

- Deleting the document resets Session Manager preferences, so the next session won't point at a deleted bucket.
- Before you delete the session-log bucket, you may want to keep `session-log.txt` (already on your laptop) as a sample for your notes.
- `lab3-bucket-akash` (created Nov 21, tagged `Project=aws-practice`) looks like an earlier level's. I'm leaving it unless you tell me to remove it.

## Step 8: IAM, read-only first

```
aws iam list-attached-role-policies --role-name lab3-ec2-ssm --query 'AttachedPolicies[].PolicyArn' --output text
aws iam list-attached-group-policies --group-name kovai-admins --query 'AttachedPolicies[].PolicyArn' --output text
aws iam list-group-policies --group-name kovai-admins --output text
aws iam list-mfa-devices --user-name admin --query 'MFADevices[].SerialNumber' --output text
aws iam list-groups-for-user --user-name akash --query 'Groups[].GroupName' --output text
```

- Your earlier listing showed `akash` in the group `lab3-admin`, and `admin` in `kovai-admins`. Don't delete `akash` or `lab3-admin`, since that is your own login.
- Tell me whether `admin` is your Level 3 test user, and I'll give the exact delete commands.

## Final check after Steps 6 to 8

```
aws resourcegroupstaggingapi get-resources --region ap-south-1 --tag-filters Key=Project,Values=aws-practice --query 'ResourceTagMappingList[].ResourceARN' --output text
aws ec2 describe-addresses --region ap-south-1
```

Only `lab3-bucket-akash` should remain (if you keep it), and there should be no Elastic IPs.

## Self-check
- Why must the gateway endpoint be deleted before the route table?
- Why is the route table you created deleted separately from the VPC's main route table?

**Exam relevance (SAP-C03):** teardown follows dependencies: ENIs, then security groups, then subnets, then the VPC. Terraform works that graph out for you, which is the point of the rebuild.

Paste the Step 6 and 7 outputs and the Step 8 reads, and I'll finish the IAM cleanup.

---

**You** (24 Nov 2026, 1:45 pm)

PS C:\Users\asgha\Desktop\AWS> aws iam list-attached-role-policies --role-name lab3-ec2-ssm --query 'AttachedPolicies[].PolicyArn' --output text
>> aws iam list-attached-group-policies --group-name kovai-admins --query 'AttachedPolicies[].PolicyArn' --output text
>> aws iam list-group-policies --group-name kovai-admins --output text
>> aws iam list-mfa-devices --user-name admin --query 'MFADevices[].SerialNumber' --output text
>> aws iam list-groups-for-user --user-name akash --query 'Groups[].GroupName' --output text
>> 
arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore                                                                                                         

POLICYNAMES     lab3-kovai-admins-policy                                                                                                                     


aws: [ERROR]: An error occurred (NoSuchEntity) when calling the ListMFADevices operation: The user with name admin cannot be found.
admin                                                                                                                                                        

PS C:\Users\asgha\Desktop\AWS> aws resourcegroupstaggingapi get-resources --region ap-south-1 --tag-filters Key=Project,Values=aws-practice --query 'ResourceTagMappingList[].ResourceARN' --output text
>> aws ec2 describe-addresses --region ap-south-1
>> 
arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-094a37e0c48dcb545 arn:aws:s3:::lab3-bucket-akash  arn:aws:ec2:ap-south-1:908402822288:instance/i-034eaffd299e9c196        arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-01ec6dc06fec298e5 arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-0dcad0778cfddbcbc arn:aws:ec2:ap-south-1:908402822288:vpc-endpoint/vpce-059714bff2e7e9817

{                                                                                                                                                            
    "Addresses": []
}

PS C:\Users\asgha\Desktop\AWS>

---

**Tutor** (24 Nov 2026, 1:45 pm)

## Good news and one correction

### Where you are
- Billing is already stopped. Only the free S3 gateway endpoint remains, and no Elastic IPs exist.
- The tag check still lists the old instance and interface endpoints. That's the tagging index lagging (it can take up to an hour). It doesn't mean they still exist. Trust `describe-vpc-endpoints` and `describe-instances`, which showed them gone.
- Steps 6 and 7 have not been run yet. The gateway endpoint, security groups, subnet, route table, VPC, buckets and SSM document are all still there.

### Correction on my IAM assumption
The earlier IAM listing was misleading, and I misread it. The error says there is no IAM **user** named `admin`. The last command shows `akash` belongs to the group **`admin`**, not `lab3-admin`. So:
- `admin` is a **group** that your own user `akash` is in. **Do not delete it, and do not delete `lab3-admin`.** Either could be what gives you your own permissions.
- `kovai-admins` is the Level 3 group (it has the inline policy `lab3-kovai-admins-policy`). Safe to delete.
- No test user exists, so there are no MFA devices to remove.

### Run Steps 6 and 7 now
Run them exactly as in my previous message (network first, then the SSM document and buckets). The ID lists are unchanged.

### Step 8: IAM cleanup (the Level 3 pieces only)
First check nobody is in the group:
```
aws iam get-group --group-name kovai-admins --query 'Users[].UserName' --output text
```
If that prints nothing, run:
```
aws iam delete-group-policy --group-name kovai-admins --policy-name lab3-kovai-admins-policy
aws iam delete-group --group-name kovai-admins
```
If it prints a user name, paste it and I'll give the removal command. Don't remove `akash` from any other group.

Then the instance role, which I'll fill in with your real names:
```
aws iam remove-role-from-instance-profile --instance-profile-name lab3-ec2-ssm --role-name lab3-ec2-ssm
aws iam delete-instance-profile --instance-profile-name lab3-ec2-ssm
aws iam detach-role-policy --role-name lab3-ec2-ssm --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam delete-role-policy --role-name lab3-ec2-ssm --policy-name lab3-inline-s3
aws iam delete-role --role-name lab3-ec2-ssm
```

### Optional: the Nov 21 bucket
`lab3-bucket-akash` is tagged `Project=aws-practice` and costs about $0. Say the word if you want it removed, and I'll first give a read-only listing of what's in it.

### Final check
After Steps 6 to 8:
```
aws ec2 describe-vpcs --region ap-south-1 --query 'Vpcs[].[VpcId,IsDefault]' --output text
aws s3 ls
aws iam list-roles --query 'Roles[?starts_with(RoleName,`lab3`)].RoleName' --output text
```
Expect only the default VPC, at most `lab3-bucket-akash`, and no `lab3` roles. The tag check will go clean within the hour.

### Cost
Total is roughly $0.25-0.30, under the USD 1 cap. Nothing bills overnight.

**Self-check:** Why does the tag API still list resources that `describe-*` says are gone?

**Exam relevance (SAP-C03):** the Resource Groups Tagging API is eventually consistent, so verify deletion with each service's own describe call.

Paste the Step 6 and 7 outputs and the `get-group` result.

---

**You** (24 Nov 2026, 1:46 pm)

PS C:\Users\asgha\Desktop\AWS> aws iam get-group --group-name kovai-admins --query 'Users[].UserName' --output text
>> 
lab3-admin                                                                                                                                                   

PS C:\Users\asgha\Desktop\AWS> aws iam delete-group-policy --group-name kovai-admins --policy-name lab3-kovai-admins-policy
>> aws iam delete-group --group-name kovai-admins
>> 

aws: [ERROR]: An error occurred (DeleteConflict) when calling the DeleteGroup operation: Cannot delete entity, must remove users from group first.
PS C:\Users\asgha\Desktop\AWS> aws iam remove-role-from-instance-profile --instance-profile-name lab3-ec2-ssm --role-name lab3-ec2-ssm
PS C:\Users\asgha\Desktop\AWS> aws iam delete-instance-profile --instance-profile-name lab3-ec2-ssm
PS C:\Users\asgha\Desktop\AWS> aws iam detach-role-policy --role-name lab3-ec2-ssm --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
PS C:\Users\asgha\Desktop\AWS> aws iam delete-role-policy --role-name lab3-ec2-ssm --policy-name lab3-inline-s3
PS C:\Users\asgha\Desktop\AWS> aws iam delete-role --role-name lab3-ec2-ssm
PS C:\Users\asgha\Desktop\AWS> 
PS C:\Users\asgha\Desktop\AWS> aws ec2 describe-vpcs --region ap-south-1 --query 'Vpcs[].[VpcId,IsDefault]' --output text
vpc-011c6227ea559561e   True                                                                                                                                 

PS C:\Users\asgha\Desktop\AWS> aws s3 ls
2026-11-21 20:09:11 lab3-bucket-akash
PS C:\Users\asgha\Desktop\AWS> aws iam list-roles --query 'Roles[?starts_with(RoleName,`lab3`)].RoleName' --output text

---

**Tutor** (24 Nov 2026, 1:46 pm)

## Almost clean, and I need to correct myself first

The DeleteConflict is the useful part. `get-group` printed `lab3-admin` as a **user** in `kovai-admins`. So `lab3-admin` is an IAM user, and I was wrong earlier when I called it a group. The earlier `list-users` output (`akash   lab3-admin`) was a user name paired with a group name in a different list. I misread it.

Because `akash` showed `admin` as a group, and `lab3-admin` is a user, I can't be sure which identity you are signed in as. Don't guess.

### Check before touching `kovai-admins`
```
aws sts get-caller-identity --query Arn --output text
```
- If it shows `user/lab3-admin`, you are that user. The `kovai-admins` group holds the inline policy you just deleted, so any permissions it gave you are already gone. Leave the group membership alone for now and check your other access (below) before removing anything else.
- If it shows `user/akash`, then `lab3-admin` is a separate user and it is safe to remove from the group.

Then see what else gives that user access:
```
aws iam list-groups-for-user --user-name lab3-admin --query 'Groups[].GroupName' --output text
aws iam list-attached-user-policies --user-name lab3-admin --query 'AttachedPolicies[].PolicyArn' --output text
```
**Only if `lab3-admin` is not the identity you are using, or it has other groups or policies giving you admin access**, run:
```
aws iam remove-user-from-group --group-name kovai-admins --user-name lab3-admin
aws iam delete-group --group-name kovai-admins
```
Do not delete the user `lab3-admin` or the group `admin`. They may be your own login.

### What is already clean
- Role `lab3-ec2-ssm`, its instance profile and both policies: deleted.
- Only the default VPC remains, so Step 6 appears to have been done. The lab VPC is gone.
- Only `lab3-bucket-akash` is left in S3. The two lab buckets are gone, so Step 7 is done too.

### Remaining read-only checks
```
aws ssm describe-document --name SSM-SessionManagerRunShell --region ap-south-1 --query Document.Name --output text
aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].VpcEndpointId' --output text
aws ec2 describe-instances --region ap-south-1 --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text
aws ec2 describe-volumes --region ap-south-1 --query 'Volumes[].VolumeId' --output text
```
If the SSM document still exists, tell me. I'll give the delete command.

### The Nov 21 bucket
`lab3-bucket-akash` costs about $0. Want it gone? I'll give a read-only `aws s3 ls s3://lab3-bucket-akash --recursive` first.

### Cost
Nothing is billing. The exercise cost roughly $0.25-0.30, under the USD 1 cap.

**Self-check:** Why did `delete-group` fail even after the group's policy was deleted?

**Exam relevance (SAP-C03):** IAM deletion order is policies, then members, then the entity. A group can't be deleted while users are in it.

Paste the `get-caller-identity` and the four read-only outputs, and then we plan the Terraform rebuild in small pieces.

---

**You** (24 Nov 2026, 1:47 pm)

can we skip now othe rthings

---

**Tutor** (24 Nov 2026, 1:47 pm)

## Yes, you can skip the rest

Everything that costs money is already gone. What's left is free:
- **`kovai-admins` group and the `lab3-admin` user:** IAM is free. Leave them alone, because I'm not sure which identity you sign in as.
- **`lab3-bucket-akash`:** an empty or near-empty bucket costs about $0. Keep it or delete it later.
- **Tag API still listing old resources:** that's lag and clears within the hour.
- **Replacement test:** you skipped it, so do it in the Terraform rebuild.

### One 30-second check before you move on (read-only)
```
aws ec2 describe-vpc-endpoints --region ap-south-1 --query 'VpcEndpoints[].VpcEndpointId' --output text
aws ec2 describe-instances --region ap-south-1 --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text
aws ec2 describe-volumes --region ap-south-1 --query 'Volumes[].VolumeId' --output text
aws ec2 describe-addresses --region ap-south-1 --query 'Addresses[].AllocationId' --output text
```
All four should print nothing. Your earlier output already showed that for the VPC, buckets and role.

### One thing worth a single command
If the Session Manager preferences document still exists, it points at a deleted bucket and will break your next session. Check:
```
aws ssm describe-document --name SSM-SessionManagerRunShell --region ap-south-1 --query Document.Name --output text
```
If it prints the name, run `aws ssm delete-document --name SSM-SessionManagerRunShell --region ap-south-1`. If it errors with "does not exist", you're fine.

### Cost
Nothing is billing. The exercise cost roughly $0.25-0.30, under the USD 1 cap.

### Next: the Terraform rebuild (time-box about 1 hour)
We'll do it in small pieces, and I'll give the next piece only. The order:
1. Provider, default tags (`Project=aws-practice`) and the VPC with a private subnet and route table.
2. Security groups, then the S3 gateway endpoint.
3. IAM role and instance profile, then the log bucket.
4. Instance, then the interface endpoints (these are the billed part, so they come last and get destroyed right after testing).

Also add `.gitignore` entries for `*.tfstate*` and `.terraform/` before your first `terraform init`, so state never reaches Git.

**Self-check:** Why should the billed interface endpoints be the last thing you create in Terraform?

Tell me when the four checks are clean, and we'll start with piece 1.

---

**You** (24 Nov 2026, 1:51 pm)

what interfaces we created

---

**Tutor** (24 Nov 2026, 1:51 pm)

## The three interface endpoints you created

All three were in your one lab subnet, with `endpoint-sg` (inbound TCP 443 from `ec2-sg`) and Private DNS on. They are now deleted.

| Endpoint | Service name | What it does | Symptom if missing |
|---|---|---|---|
| ssm | `com.amazonaws.ap-south-1.ssm` | The agent registers with Systems Manager and calls its API | Instance never shows Online in `describe-instance-information` |
| ssmmessages | `com.amazonaws.ap-south-1.ssmmessages` | The live channel for the shell session (the data stream between you and the server) | Instance shows Online, but `start-session` fails or the shell won't open |
| ec2messages | `com.amazonaws.ap-south-1.ec2messages` | The agent receives messages and commands from the service | Agent can't poll for commands, so Run Command and some session features break |

Short way to remember: **ssm** = API, **ssmmessages** = session channel, **ec2messages** = command delivery.

## The one gateway endpoint (not an interface)
- `com.amazonaws.ap-south-1.s3`, type **Gateway**.
- It lives in the **route table** as a prefix-list route (you saw `pl-78a54011` pointing at `vpce-094a...`), not as an ENI in your subnet.
- Interface endpoints are ENIs with private IPs in your subnet. They bill about $0.011/hr each per AZ plus about $0.01/GB, so about $0.033/hr for three. The gateway endpoint is free.

## Interview line you can use
"I used three interface endpoints (ssm, ssmmessages, ec2messages) in one AZ, about $0.033/hr, and a free S3 gateway endpoint, instead of a NAT Gateway at roughly $40+/month."

**Exam relevance (SAP-C03):** Session Manager without internet needs these three interface endpoints. Add `logs` (CloudWatch Logs) or `kms` only if you log to CloudWatch or encrypt with a KMS key. S3 logging needs just the free gateway endpoint.

**Self-check:** Which one of the three would you notice missing first, and how?

---

**You** (24 Nov 2026, 1:53 pm)

difference between gateway we used for s3 and why we used that and gateway and interface difference

---

**Tutor** (24 Nov 2026, 1:53 pm)

## Gateway vs interface endpoints

| | **Gateway endpoint** | **Interface endpoint** |
|---|---|---|
| How it works | A **route table entry**: a prefix list (`pl-78a54011` for S3) pointing at `vpce-094a...` | An **ENI with a private IP** in your subnet |
| Where it lives | In the route table, not in a subnet | In the subnet(s) you pick, one ENI per AZ |
| Services | **Only S3 and DynamoDB** | Most other AWS services (SSM, ssmmessages, ec2messages, KMS, CloudWatch Logs, etc.) and PrivateLink services |
| Cost | **Free** | ~$0.011/hr per AZ (~$8/month per AZ) plus ~$0.01/GB processed |
| Security group | **None**. Control it with route tables and endpoint policies | **Yes**. You attach a SG (yours allowed TCP 443 from `ec2-sg`) |
| DNS | The normal S3 name resolves to public IPs, but the route sends traffic over the AWS network | **Private DNS** makes the normal service name resolve to the ENI's private IP |
| Reach from on-premises, VPN or another VPC | **No**. Only works from inside the VPC it's attached to | **Yes**. Reachable over VPN, Direct Connect or peering, since it's just a private IP |
| Policy | Endpoint policy | Endpoint policy plus security group |

## Why we used a gateway endpoint for S3
- Your server needed S3 for the session-log upload, and the instance role writes the transcripts there.
- A gateway endpoint gives a private path to S3 with **no internet, no NAT**, at **$0**.
- An S3 interface endpoint would have added ~$0.011/hr for no benefit in this design, because nothing needed to reach S3 from outside the VPC.
- The proof you already have: `curl google.com` timed out, but `aws s3 cp` to your bucket worked.

## Why SSM needed interface endpoints
- SSM, ssmmessages and ec2messages have **no gateway option**. Gateway endpoints exist only for S3 and DynamoDB.
- So the private path to them must be an interface endpoint (ENI), and that's the part that costs money.

## Quick correction to your earlier guess
You said the gateway "sits in the public domain". The S3 name does resolve to public IPs, which is probably where the thought came from. But the route-table entry sends that traffic over the AWS private network, so it never goes out to the internet.

## Cost recap
- Gateway: $0.
- Three interface endpoints in one AZ: ~$0.033/hr.
- NAT Gateway alternative: ~$0.056/hr plus data, so roughly $40+/month, which the customer ruled out.

**Exam relevance (SAP-C03):** know that gateway endpoints are S3/DynamoDB only, free, route-table based and not reachable from on-premises. Use an S3 **interface** endpoint if on-premises or another VPC must reach S3 privately.

**Self-check:** A customer's on-premises servers need to reach S3 privately over a VPN. Which endpoint type do you use, and why won't the gateway one work?

---

**You** (24 Nov 2026, 1:54 pm)

internet gateway

---

**Tutor** (24 Nov 2026, 1:54 pm)

## Internet gateway (IGW)

**What it is:** A free, horizontally scaled VPC component that connects a VPC to the internet. One IGW attaches to one VPC.

### What makes a subnet "public"
A subnet is public only when all three are true:
1. The VPC has an IGW attached.
2. The subnet's route table has `0.0.0.0/0 → igw-xxxx`.
3. The instance has a public IPv4 (or Elastic IP).

Miss any one and the instance has no direct internet path.

### What the IGW does
- Routes traffic in and out of the VPC.
- Does a 1:1 NAT between an instance's private IP and its public IPv4.
- Supports inbound connections, which is why a public SG rule on port 22 (the customer's problem) was reachable from anywhere.

### IGW vs NAT Gateway
| | **Internet gateway** | **NAT Gateway** |
|---|---|---|
| Direction | Two-way | Outbound only (private instances to internet) |
| Needs public IP on instance | Yes | No (the NAT has the Elastic IP) |
| Cost | **Free** | ~$0.056/hr plus ~$0.056/GB, so ~$40+/month |
| Lives in | Attached to the VPC | A public subnet |

### In your Level 3 build
- Your lab VPC had **no IGW**, so `0.0.0.0/0` had nowhere to go.
- Your route table only had `local` and the S3 prefix-list route.
- That's why `curl google.com` timed out, and it's exactly what the customer wanted.
- Your **default VPC** does have an IGW (`igw-07239733...`). You saw it in the discovery output. Leave it alone.

### Terraform preview (one concept, not part of this level's answer)
For a public subnet you would need:
```hcl
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
}
```
Plus a `0.0.0.0/0` route to it. **Level 3 deliberately has neither.** Don't add them.

### Cost
The IGW is free. A public IPv4 address costs ~$0.005/hr, so ~$3.60/month per address even while attached to a running instance.

**Exam relevance (SAP-C03):** know the pattern: IGW for public two-way access, NAT Gateway for private outbound-only, and egress-only IGW for IPv6 outbound-only.

**Self-check:** Your instance has a public IP and an IGW is attached, but it still can't reach the internet. What's the most likely missing piece?

---

**You** (24 Nov 2026, 1:57 pm)

Failure symptoms: You delete only ssmmessages. Does the instance still show PingStatus = Online? What happens when you run start-session? Then do the same for ssm alone.
Where each type lives: An interface endpoint is an ENI with a private IP in your subnet. Where does the S3 gateway endpoint show up? Think about what you saw in Phase 1 resources, not the subnet.
Cost, in numbers: Roughly what does one interface endpoint cost per hour per AZ, and what did your three cost per hour? What does the gateway endpoint cost?

---

**Tutor** (24 Nov 2026, 1:58 pm)

## Model answers (put them in your own words in the interview)

You built this, so these come from what you saw in your own account.

### 1. Failure symptoms
- **Delete only `ssmmessages`:**
  - The instance still shows `PingStatus = Online`, because the agent's check-in goes through the `ssm` endpoint.
  - `start-session` fails, because the live shell channel needs `ssmmessages`.
  - Say it like this: "Online in the list, but I can't open a shell."
- **Delete only `ssm`:**
  - The agent can't register or check in, so the instance never shows Online. An already-registered instance drops to `ConnectionLost` after a few minutes.
  - `start-session` fails with a "TargetNotConnected" error.
  - Say it like this: "The instance is invisible to Systems Manager."
- **Bonus on `ec2messages`:** older agents use it to receive Run Command messages. Newer SSM Agent versions can fall back to `ssmmessages`, so it may not be strictly required. The brief and the checklist keep all three, and AWS docs list it as required, so build it that way.

### 2. Where each type lives
- **Interface endpoint:** an ENI with a private IP in your subnet.
- **S3 gateway endpoint:** an entry in your **route table**, not the subnet.
  - You saw it in the route output as `DestinationPrefixListId: pl-78a54011` with `GatewayId: vpce-094a37e0c48dcb545`.
  - It's a route to the S3 prefix list that sends traffic over the AWS network. No ENI and no security group are involved.

### 3. Cost in numbers
- One interface endpoint: about **$0.011/hr per AZ**, plus about $0.01/GB processed.
- Your three in one AZ: about **$0.033/hr**, so about $0.80/day if left overnight.
- Gateway endpoint: **$0**.
- Whole lab: about $0.25-0.30, under the USD 1 cap.

### Practice line
"I used ssm, ssmmessages and ec2messages interface endpoints in one AZ, about $0.033/hr, and a free S3 gateway endpoint in the route table, instead of a NAT Gateway at roughly $40+/month. Without ssmmessages the instance still showed Online but I couldn't open a shell. Without ssm it never registered."

**Exam relevance (SAP-C03):** you should be able to name which endpoint's absence causes which symptom, and when a gateway endpoint can't be used (on-premises access).

**Self-check:** Write the 3 answers above from memory in your own words, then paste them back and I'll give feedback like the interviewer would.

---

**You** (24 Nov 2026, 2:03 pm)

2 AZs: You have 3 interface endpoints at about $0.011/hr per endpoint per AZ, and a month has about 730 hours. What is the monthly cost in 1 AZ, and what is it in 2 AZs?
10 servers: Is an interface endpoint billed per server or per endpoint per AZ? Based on that, does adding 9 more servers change the hourly endpoint bill? What does grow with more servers?
NAT in numbers: A NAT Gateway costs about $0.056/hr plus about $0.056/GB. For resilience you would want one per AZ. Roughly what is that per month for 2 AZs before any data charges? Is that more or less than your answer to #1?

this tough question people really ask?

---

**Tutor** (24 Nov 2026, 2:04 pm)

## Yes, people ask this, but it's arithmetic, not a trick

Cost-at-scale questions are standard in Solutions Architect interviews and in SAP-C03 scenarios. Nobody expects exact pennies. They want to see that you know **what the bill scales with**. Rounded numbers and a clear method are enough.

### 1. Endpoints, 1 AZ vs 2 AZs
- 3 endpoints x $0.011/hr x 730 hr = **~$24/month in 1 AZ**
- 2 AZs doubles it: **~$48/month**
- Rule: the bill is **per endpoint, per AZ, per hour**.

### 2. 1 server vs 10 servers
- Endpoints are **not billed per server**. Ten servers in the same VPC share the same endpoints, so the **hourly fee stays the same**.
- What grows is the **per-GB data charge** (~$0.01/GB), because more servers push more traffic through them. Session traffic is tiny, so this stays small.
- Interview line: "Fixed cost per AZ, variable cost per GB. Adding servers doesn't add endpoints."

### 3. NAT Gateway comparison
- 1 NAT x $0.056/hr x 730 = ~$41/month
- 2 AZs (one per AZ for resilience) = **~$82/month before data charges**
- Plus ~$0.056/GB processed.
- So NAT is roughly **$82 vs $48**, about 1.7x more, and it opens an outbound internet path (exfiltration and malware-download risk). Endpoints keep traffic on the AWS network.

### Honest caveat (this shows depth)
NAT isn't always more expensive. NAT is a flat fee for **all** internet-bound services. Interface endpoints are per service, so if you needed 10+ different endpoints per AZ, the total could pass NAT. And if the servers need the real internet (patching from public repos, third-party APIs), endpoints can't replace NAT. Saying this in an interview scores well.

### How to answer in 20 seconds
"Three interface endpoints cost about $24 a month per AZ, so about $48 across two AZs. That's a fixed cost, not per server, so ten servers don't change it, only the small per-GB charge grows. Two NAT Gateways would be about $82 a month plus data, and they open an outbound internet path, so endpoints win here unless we need many more services or real internet access."

### Cost
This is theory only. Nothing is running, and your lab cost about $0.25-0.30, under the USD 1 cap.

**Exam relevance (SAP-C03):** cost-optimisation questions often hinge on "fixed per-AZ cost vs per-GB cost" and on gateway endpoints being free.

**Self-check:** Without looking, what is the monthly cost of 3 endpoints in 3 AZs?

Want to go back to the interviewer's Q2 and answer it in your own words? I'll give feedback like they would.

---

**You** (24 Nov 2026, 2:05 pm)

give me example of nat costs more than inteface

---

**Tutor** (24 Nov 2026, 2:05 pm)

## When NAT costs more than interface endpoints

NAT costs more when **data volume is high** or you need **few endpoints**. Interface endpoints win when the endpoint count is small and the traffic is modest.

Rates used (ap-south-1, approximate): NAT ~$0.056/hr + ~$0.056/GB. Interface endpoint ~$0.011/hr per AZ + ~$0.01/GB. Check the current pricing pages before quoting these in an interview.

### Example 1: Your Level 3 design, 2 AZs, light traffic
| | Hourly fee (730 hr) | Data (50 GB/month) | Total |
|---|---|---|---|
| 3 endpoints x 2 AZs | ~$48 | ~$0.50 | **~$48.50** |
| 2 NAT Gateways | ~$82 | ~$2.80 | **~$85** |

NAT is about 1.7x more, and it adds an outbound internet path.

### Example 2: Heavy data, one service
An app in 1 AZ pulls **2 TB (2,000 GB)/month** from one AWS service, say ECR image pulls or CloudWatch Logs.

| | Hourly fee | Data | Total |
|---|---|---|---|
| 1 interface endpoint (1 AZ) | ~$8 | ~$20 | **~$28** |
| 1 NAT Gateway | ~$41 | ~$112 | **~$153** |

NAT is about 5x more. The per-GB charge is where NAT hurts: it is about 5x the endpoint's per-GB rate.

### Example 3: S3 traffic through NAT (the classic mistake)
Servers read **5 TB/month** from S3 via a NAT Gateway.
- NAT data: 5,000 GB x $0.056 = **~$280/month**, plus ~$41 for the hourly fee.
- Free S3 gateway endpoint: **$0**.

This is the most common exam answer for "reduce NAT cost": add a free gateway endpoint for S3 and DynamoDB.

### Where NAT is cheaper (for balance)
If you need **15+ different endpoints per AZ** (~$0.011 x 15 x 730 = ~$120/month) and traffic is low, one NAT at ~$41 can be cheaper. NAT is also the only option if servers need the real internet, such as public patch repos or third-party APIs.

### Interview line
"NAT charges per GB at about five times the endpoint rate, so high-volume traffic to AWS services is far cheaper through endpoints, and S3 or DynamoDB traffic should always use the free gateway endpoint."

### Cost
This is theory only. Nothing is running, and your lab cost about $0.25-0.30, under the USD 1 cap.

**Exam relevance (SAP-C03):** "Reduce NAT Gateway data processing charges" is a recurring pattern. The answer is usually a gateway endpoint for S3/DynamoDB, or interface endpoints for the heavy AWS services.

**Self-check:** Servers move 3 TB/month to S3 through a NAT Gateway. Which single change cuts that cost the most, and what does it cost?

---

**You** (24 Nov 2026, 2:07 pm)

so you are syaing nat don't matter how many connection and interface count connectons

---

**Tutor** (24 Nov 2026, 2:07 pm)

## Not quite: both depend on *different* things

**NAT Gateway bill** = hourly fee per NAT + per GB processed.
- It does **not** change with the number of servers, connections, or AWS services you reach. One NAT serves all of them.
- It only changes with the **number of NATs** (one per AZ for resilience) and the **GB** pushed through.

**Interface endpoint bill** = hourly fee per endpoint per AZ + per GB.
- It **does** grow with the number of endpoints, meaning how many different AWS services you need privately, multiplied by AZs.
- It does **not** change with the number of servers.

| Cost driver | NAT Gateway | Interface endpoints |
|---|---|---|
| More servers | No change to hourly fee | No change to hourly fee |
| More AWS services reached | No change | **+~$8/month per endpoint per AZ** |
| More AZs | +~$41/month per AZ | +~$8/month per endpoint per AZ |
| More GB | ~$0.056/GB | ~$0.01/GB |

### Break-even (hourly fees only, same AZ count)
- One NAT is ~$41/month. One endpoint is ~$8/month.
- So at about **5 endpoints per AZ**, the endpoints' hourly fees match one NAT.
- With 3 endpoints (your design), endpoints are cheaper: ~$24 vs ~$41 per AZ.
- With 8 endpoints, ~$64 vs ~$41, so NAT is cheaper on the hourly fee alone.

### Correction to my last message
I said NAT only wins at "15+ endpoints per AZ". That was too high. The hourly crossover is about **5 per AZ**. The per-GB gap (NAT at about 5x the rate) pushes it back the other way as traffic grows. So the real answer is: **it depends on endpoint count and GB together**.

### Why endpoints still won for Kovai
- Only 3 endpoints were needed, so the fixed cost stayed low.
- Traffic was tiny.
- The auditors wanted **no outbound internet path**, which NAT can't give. This reason matters more than cost here.

### One real NAT limit (not a billing item)
A NAT Gateway supports about 55,000 simultaneous connections to a single destination. That's a scaling limit, not something you pay per connection for.

### Interview line
"NAT is a flat fee that doesn't grow with services or servers, only with AZs and GB. Interface endpoints grow with endpoints times AZs. Below about five endpoints per AZ with modest traffic, endpoints are cheaper, and they also keep the VPC with no internet path."

### Cost
Theory only. Nothing is running.

**Exam relevance (SAP-C03):** know that endpoint cost scales with services times AZs, NAT cost scales with AZs and GB, and S3/DynamoDB gateway endpoints are free in either design.

**Self-check:** A VPC needs 8 AWS services privately, in 2 AZs, with very little traffic. Roughly what do endpoints cost per month, and what do 2 NATs cost?

### Score: 4.5/10

- Requirements: 6
- Architecture: 6
- Security: 6
- Cost: 5
- Resilience: 3
- Communication: 3

You built a correct private SSM design: a private subnet with no IGW route, a security group with no inbound rules, an instance role, three interface endpoints plus a free S3 gateway endpoint, and session logs in an encrypted bucket with Block Public Access on. Your customer questions on admins, retention, RTO/RPO and services were solid. The interview showed thin recall: answers came as formulas or a few words, the rebuild/DR answers were weak (user data only, then a costly Route 53 Resolver idea), and the interview stopped at Q3. The tutor chat also shows the replacement test was skipped and the IAM/bucket cleanup is incomplete, so two ticked checks were not actually done.

**3 biggest improvements**
1. Answer with finished numbers and specifics: about $24/month for 3 endpoints in 1 AZ, about $48 in 2 AZs, about $82 for 2 NATs before data. Name the status values (Online / ConnectionLost) and the errors (TargetNotConnected). Explain the hourly break-even of about 5 interface endpoints per AZ versus one NAT, and the per-GB gap of about $0.056 for NAT versus about $0.01 for endpoints.
2. Learn the RTO/RPO pattern. A launch template holds the AMI, type, role, subnet and SG. An Auto Scaling group with min/max 1 replaces a dead instance automatically. AWS Backup or Data Lifecycle Manager takes daily EBS snapshots with about 7-30 days retention, roughly $0.40/month for 8 GB. In production, add interface endpoints in a second AZ (about +$24/month). Never use Route 53 Resolver endpoints for this; they cost about $180/month.
3. Finish what you tick. Run the replacement-instance test in the Terraform rebuild. Close out cleanup: remove lab3-admin from kovai-admins and delete the group only after confirming your identity with get-caller-identity, delete lab3-bucket-akash, and delete the custom Session Manager preferences document. Build the vendor's restricted access as a custom SSM session document (a constrained shell or allowed commands only) plus an IAM policy limited to that document. Add S3 Object Lock or MFA delete with a deny-delete bucket policy so audit logs are tamper-resistant.

**Missed clarifying questions**
- What does 'who did what' mean to the auditors: only who opened a session and when (CloudTrail), or a full keystroke/command transcript (Session Manager logging)? Must the records be tamper-proof (Object Lock / WORM)?
- How sensitive is the inventory and supplier data? Do auditors expect customer-managed KMS keys for logs, volumes and backups? (This adds a kms interface endpoint at about $8/month per AZ.)
- Does the server ever need internet access, for example for OS patches or third-party packages? Or can patching go through S3/SSM Patch Manager repositories only?
- Will more servers or other workloads move to AWS later, so the VPC and endpoints should be designed to be shared?
- How comfortable is the team with the AWS CLI and Console? Do they need a one-click or one-command way in, and training to move away from PuTTY?
- Should the vendor's access be time-bound (for example, enabled only on his monthly visit day) and approved by someone each time?
- Do you already have an identity provider (Microsoft 365 / Active Directory) that admins could federate from, instead of separate IAM users?

**Reference architecture**

- Custom VPC 10.20.0.0/16 in ap-south-1 with DNS resolution and DNS hostnames enabled. No IGW, no NAT, no Elastic IP. All resources tagged Project=aws-practice.
- One private subnet for the lab (two private subnets in two AZs for production). Route table holds only the local route and the S3 prefix-list route.
- ec2-sg: no inbound rules; outbound limited to 443 to endpoint-sg and the S3 prefix list. endpoint-sg: inbound TCP 443 from ec2-sg only.
- Interface endpoints with Private DNS: ssm, ssmmessages, ec2messages, about $0.033/hr in 1 AZ. Create them right before testing and delete them right after.
- S3 gateway endpoint ($0) for session logs and app packages/config, with an endpoint policy limited to the company buckets.
- EC2 t4g.micro running Amazon Linux 2023 arm64, 8 GB gp3, no public IP, no key pair, IMDSv2 required.
- IAM instance role: AmazonSSMManagedInstanceCore, plus a scoped policy for s3:PutObject on the log bucket prefix and s3:GetObject on the app/config prefix.
- Session Manager preferences: S3 logging to a dedicated bucket with Block Public Access on, SSE-S3 encryption (SSE-KMS only if required; that adds a kms endpoint), a 365-day lifecycle rule, and Object Lock (governance) or a deny-delete bucket policy for tamper resistance.
- CloudTrail trail (the first trail's management events are free) to a separate locked-down bucket. It records who ran StartSession/TerminateSession and when.
- Identity: named IAM users with MFA in group kovai-admins, allowed ssm:StartSession on instances tagged Project=aws-practice (or on the instance ARN) and ssm:TerminateSession / ResumeSession only on their own sessions. In production, use IAM Identity Center or federation once Organizations is allowed (later level).
- Vendor: separate user/group allowed StartSession only with a custom SSM session document (for example, an InteractiveCommands document that tails app logs and runs systemctl restart for the app), with no access to the default shell document. Every command is logged.
- Resilience: a launch template (AMI, type, profile, subnet, SG, tags, user data pulling config from S3) and an Auto Scaling group with min=max=1, so a dead instance is replaced and back Online in minutes with no keys. Data is restored from snapshots or held on S3.
- Backup for 1-day RPO: AWS Backup or DLM daily EBS snapshots with 7-30 day retention, about $0.40/month for 8 GB incremental.
- Production cost estimate: t4g.micro about $6, gp3 about $0.70, endpoints in 2 AZs about $48 (or about $24 in 1 AZ if accepting AZ risk), snapshots about $0.40. Compare against 2 NAT Gateways at about $82/month before data charges.
- Terraform: remote state in an encrypted, versioned S3 bucket (not in Git), a .gitignore covering *.tfstate and .terraform, and default_tags { Project = aws-practice }.

**SAP-C03 domain map**
- Endpoint versus NAT cost math (monthly figures, per-AZ scaling, per-GB rates, about 5 endpoints per AZ break-even): Domain 4: Continuous Improvement for Existing Solutions (cost optimization)
- Automated recovery to meet RTO 30 min / RPO 1 day (launch template, ASG of 1, AWS Backup/DLM snapshots, multi-AZ endpoints): Domain 2: Design for New Solutions (business continuity / reliability)
- Proposing Route 53 Resolver endpoints for an SSM design; not knowing that Private DNS on interface endpoints already handles name resolution: Domain 1: Design Solutions for Organizational Complexity (network connectivity / hybrid DNS)
- Audit evidence: CloudTrail (who started a session) versus Session Manager logging (what was typed), and tamper-proof logs with Object Lock: Domain 2: Design for New Solutions (security controls)
- Least-privilege vendor access via custom SSM session documents and IAM conditions: Domain 1: Design Solutions for Organizational Complexity (security and access control)
- Incomplete verification and cleanup (skipped replacement test, leftover IAM user/group, bucket and SSM document): Domain 4: Continuous Improvement for Existing Solutions (operational excellence)

