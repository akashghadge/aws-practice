# SA Coach Studio export

Exported 21 Nov 2026, 12:43 am. Contains every level's brief, checklist, notes, customer/interviewer chat, tutor chat and score.

## Scores

No levels scored yet.

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

Phase: done. Hints used: 3.

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

Phase: done. Hints used: 0.

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
- [ ] aws ec2 describe-vpcs --region ap-south-1 --filters Name=tag:Project,Values=aws-practice returns exactly one VPC, with the agreed CIDR (not overlapping 192.168.1.0/24 or 10.1.0.0/16).
- [ ] aws ec2 describe-subnets --region ap-south-1 --filters Name=vpc-id,Values=<vpc-id> returns 4 subnets: 2 public and 2 private, with one of each in ap-south-1a and one of each in ap-south-1b. Only the public subnets show MapPublicIpOnLaunch=true.
- [ ] aws ec2 describe-route-tables --region ap-south-1 --filters Name=vpc-id,Values=<vpc-id> shows a public route table with 0.0.0.0/0 -> igw-xxxx, associated with both public subnets. It also shows a private route table with only the 'local' route, associated with both private subnets.
- [ ] aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=<vpc-id> shows exactly one IGW, in state 'available'.
- [ ] aws ec2 describe-security-groups --filters Name=vpc-id,Values=<vpc-id> shows: the web SG allows 80/443 from 0.0.0.0/0; no SG allows port 22 from 0.0.0.0/0; the private SG allows inbound only from the web SG (by SG reference, not by CIDR).
- [ ] aws ec2 describe-network-acls --filters Name=vpc-id,Values=<vpc-id> shows a custom NACL associated with both private subnets. It has explicit inbound allow rules from the VPC CIDR only, plus outbound rules covering ephemeral ports 1024-65535.
- [ ] Optional live test: a t3.micro in a public subnet serves a test page (curl http://<public-ip> from your laptop works). A t3.micro in a private subnet has no public IP and cannot be reached from the internet. Then terminate both.
- [ ] Clean delete: after teardown, these all return empty results for the region: aws ec2 describe-instances --filters Name=instance-state-name,Values=running,stopped; aws ec2 describe-vpcs --filters Name=tag:Project,Values=aws-practice; aws ec2 describe-addresses; aws ec2 describe-nat-gateways --filter Name=state,Values=available.

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

