resource "aws_rds_cluster_instance" "ll_ha" {
    count                = 2
    identifier           = "${var.tag_name}-db-${count.index}"
    cluster_identifier   = "${aws_rds_cluster.ll_ha.id}"
    instance_class       = "db.r3.large"
    publicly_accessible  = false
    db_subnet_group_name = "${aws_db_subnet_group.ll_ha.name}"
}

resource "aws_rds_cluster" "ll_ha" {
    cluster_identifier     = "${var.tag_name}-db"
    database_name          = "llcluster"
    master_username        = "lldeploy"
    master_password        = "${var.db_password}"
    db_subnet_group_name   = "${aws_db_subnet_group.ll_ha.name}"
    availability_zones     = ["${var.region}a", "${var.region}b", "${var.region}c"]
    vpc_security_group_ids = ["${aws_security_group.ll_ha_rds.id}"]
}

resource "aws_db_subnet_group" "ll_ha" {
    name        = "${var.tag_name}-db-subnet-group"
    description = "LL-Docker HA Subnet Group"
    subnet_ids  = [
        "${aws_subnet.ll_ha_a.id}",
        "${aws_subnet.ll_ha_b.id}",
        "${aws_subnet.ll_ha_c.id}",
    ]
    tags {
        Name = "${var.tag_name}-db-subnet-group"
    }
}

resource "aws_security_group" "ll_ha_rds" {
    name        = "${var.tag_name}-rds-secgroup"
    description = "LL-Docker RDS Ports"
    vpc_id      = "${aws_vpc.ll_ha.id}"

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "tcp"
        self      = true
    }

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "udp"
        self      = true
    }

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.2.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
