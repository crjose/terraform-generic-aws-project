resource "aws_route53_record" "root" {
  zone_id = var.route53-zone
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.projeto-elb.dns_name
    zone_id                = aws_lb.projeto-elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.route53-zone
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.projeto-elb.dns_name
    zone_id                = aws_lb.projeto-elb.zone_id
    evaluate_target_health = true
  }
}
