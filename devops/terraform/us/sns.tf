resource "aws_sns_topic" "sns_topic" {
  name                        = "${terraform.workspace}-US.fifo"
  fifo_topic                  = true
  content_based_deduplication = false
  tags                        = local.tags
}
