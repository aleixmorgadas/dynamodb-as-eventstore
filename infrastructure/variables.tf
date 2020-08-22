variable "dynamo-db-read_capacity" {
    type = number
    default = 1
}

variable "dynamo-db-write_capacity" {
    type = number
    default = 1
}

variable "prevent_destroy_event_journal" {
    type = bool
    default = false
}