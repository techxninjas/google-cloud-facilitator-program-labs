#!/bin/bash

BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         Build Infrastructure with Terraform on Google Cloud       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-----------------------------------------------------------------------${RESET_FORMAT}"
echo ""

# Author: Aadil Latif
# Script: TechX Ninjas Lab Setup
# Version: 1.0

# 🌍 Fetching Region
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo ""

# 🗺️ Fetching Zone
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔄 Fetching Zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo ""

# 🆔 Fetching Project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project ID...${RESET_FORMAT}"
PROJECT_ID=`gcloud config get-value project`
echo ""

# 🔢 Fetching Project Number
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}🔍 Fetching Project Number...${RESET_FORMAT}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo ""
echo ""

# 💡 Start-Up Banner
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         🚀 INITIATING THE TASK EXECUTION...          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}-------------------------------------------------------${RESET_FORMAT}"
echo ""

read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter Bucket Name: ${RESET_FORMAT}" BUCKET
export BUCKET
echo
read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter Instance Name: ${RESET_FORMAT}" INSTANCE
export INSTANCE
echo
read -p "${MAGENTA_TEXT}${BOLD_TEXT}Enter VPC Name: ${RESET_FORMAT}" VPC
export VPC
echo

instances_output=$(gcloud compute instances list --format="value(id)")

IFS=$'\n' read -r -d '' instance_id_1 instance_id_2 <<< "$instances_output"

export INSTANCE_ID_1=$instance_id_1

export INSTANCE_ID_2=$instance_id_2

touch main.tf
touch variables.tf
mkdir modules
cd modules
mkdir instances
cd instances
touch instances.tf
touch outputs.tf
touch variables.tf
cd ..
mkdir storage
cd storage
touch storage.tf
touch outputs.tf
touch variables.tf
cd

cat > variables.tf <<EOF_END
variable "region" {
 default = "$REGION"
}

variable "zone" {
 default = "$ZONE"
}

variable "project_id" {
 default = "$PROJECT_ID"
}
EOF_END

cat > main.tf <<EOF_END
terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.53.0"
        }
    }
}

provider "google" {
    project     = var.project_id
    region      = var.region
    zone        = var.zone
}

module "instances" {
    source     = "./modules/instances"
}
EOF_END

terraform init

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
    name         = "tf-instance-1"
    machine_type = "n1-standard-1"
    zone         = "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
 network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
    name         = "tf-instance-2"
    machine_type = "n1-standard-1"
    zone         =  "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}
EOF_END

terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1

terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2

terraform plan

terraform apply -auto-approve

cat > modules/storage/storage.tf <<EOF_END
resource "google_storage_bucket" "storage-bucket" {
    name          = "$BUCKET"
    location      = "us"
    force_destroy = true
    uniform_bucket_level_access = true
}
EOF_END

cat >> main.tf <<EOF_END
module "storage" {
    source     = "./modules/storage"
}
EOF_END

terraform init

terraform apply -auto-approve

cat > main.tf <<EOF_END
terraform {
    backend "gcs" {
        bucket = "$BUCKET"
        prefix = "terraform/state"
    }
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.53.0"
        }
    }
}

provider "google" {
    project     = var.project_id
    region      = var.region
    zone        = var.zone
}

module "instances" {
    source     = "./modules/instances"
}

module "storage" {
    source     = "./modules/storage"
}
EOF_END

terraform init

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
    name         = "tf-instance-1"
    machine_type = "e2-standard-2"
    zone         = "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
 network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
    name         = "tf-instance-2"
    machine_type = "e2-standard-2"
    zone         =  "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "$INSTANCE" {
    name         = "$INSTANCE"
    machine_type = "e2-standard-2"
    zone         = "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
 network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}
EOF_END

terraform init

terraform apply -auto-approve

terraform taint module.instances.google_compute_instance.$INSTANCE

terraform init

terraform plan

terraform apply -auto-approve

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
    name         = "tf-instance-1"
    machine_type = "e2-standard-2"
    zone         = "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
 network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
    name         = "tf-instance-2"
    machine_type = "e2-standard-2"
    zone         =  "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = "default"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}
EOF_END

terraform apply -auto-approve

cat >> main.tf <<EOF_END
module "vpc" {
        source  = "terraform-google-modules/network/google"
        version = "~> 6.0.0"

        project_id   = "$PROJECT_ID"
        network_name = "$VPC"
        routing_mode = "GLOBAL"

        subnets = [
                {
                        subnet_name           = "subnet-01"
                        subnet_ip             = "10.10.10.0/24"
                        subnet_region         = "$REGION"
                },
                {
                        subnet_name           = "subnet-02"
                        subnet_ip             = "10.10.20.0/24"
                        subnet_region         = "$REGION"
                        subnet_private_access = "true"
                        subnet_flow_logs      = "true"
                        description           = "Hola"
                },
        ]
}
EOF_END

terraform init

terraform plan

terraform apply -auto-approve

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
    name         = "tf-instance-1"
    machine_type = "e2-standard-2"
    zone         = "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = "$VPC"
        subnetwork = "subnet-01"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
    name         = "tf-instance-2"
    machine_type = "e2-standard-2"
    zone         = "$ZONE"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = "$VPC"
        subnetwork = "subnet-02"
    }
    metadata_startup_script = <<-EOT
                #!/bin/bash
        EOT
    allow_stopping_for_update = true
}
EOF_END

terraform init

terraform plan

terraform apply -auto-approve

cat >> main.tf <<EOF_END
resource "google_compute_firewall" "tf-firewall"{
    name    = "tf-firewall"
    network = "projects/$PROJECT_ID/global/networks/$VPC"

    allow {
        protocol = "tcp"
        ports    = ["80"]
    }

    source_tags = ["web"]
    source_ranges = ["0.0.0.0/0"]
}
EOF_END

terraform init

terraform plan

terraform apply -auto-approve

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}               ✅ ALL TASKS COMPLETED SUCCESSFULLY!            ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""
echo "${GREEN_TEXT}${BOLD_TEXT} ✔ Please check your progress."
echo "${GREEN_TEXT}${BOLD_TEXT} If it will be not completed, try again for successfully completion of the Assessment."
echo ""

for i in {1..20}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/20 seconds to check your progress\r${RESET_FORMAT}"
    sleep 1
done
echo ""

shopt -s nullglob
for file in gsp* arc* shell*; do
    [[ -f "$file" ]] && rm "$file" && echo "Removed: $file"
done
shopt -u nullglob
echo

# ✅ Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          ✅ YOU'VE SUCCESSFULLY COMPLETED THE LAB!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}🎉===========================================================${RESET_FORMAT}"
echo ""

# 📢 CTA Section
echo -e "${YELLOW_TEXT}${BOLD_TEXT}🔔 Follow for more labs & tutorials:${RESET_FORMAT}"
echo ""
echo -e "${WHITE_TEXT}${BOLD_TEXT}YouTube Channel:${RESET_FORMAT} ${BLUE_TEXT}${UNDERLINE}https://www.youtube.com/@techxninjas${RESET_FORMAT}"
echo -e "${WHITE_TEXT}${BOLD_TEXT}Join WhatsApp Group:${RESET_FORMAT} ${GREEN_TEXT}${UNDERLINE}https://chat.whatsapp.com/HosxDxImviICAwizHaXXbu${RESET_FORMAT}"
echo ""
