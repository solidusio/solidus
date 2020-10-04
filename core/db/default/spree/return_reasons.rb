# frozen_string_literal: true

Spree::ReturnReason.find_or_create_by(name: 'Better price available')
Spree::ReturnReason.find_or_create_by(name: 'Missed estimated delivery date')
Spree::ReturnReason.find_or_create_by(name: 'Missing parts or accessories')
Spree::ReturnReason.find_or_create_by(name: 'Damaged/Defective')
Spree::ReturnReason.find_or_create_by(name: 'Different from what was ordered')
Spree::ReturnReason.find_or_create_by(name: 'Different from description')
Spree::ReturnReason.find_or_create_by(name: 'No longer needed/wanted')
Spree::ReturnReason.find_or_create_by(name: 'Accidental order')
Spree::ReturnReason.find_or_create_by(name: 'Unauthorized purchase')
