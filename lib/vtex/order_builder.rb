module VTEX
  class OrderBuilder
    class << self
      def parse_order(vtex_order)
        hash_total  = build_hash_total(vtex_order)
        adjustments = hash_total['Tax'] + hash_total['Discounts'] + hash_total['Shipping']
        total_order = hash_total['Items'] + adjustments
        {
          'id'              => vtex_order['orderId'],
          'follow_up_email' => vtex_order['followUpEmail'],
          'status'          => vtex_order['status'],
          'channel'         => 'vtex',
          'origin'          => vtex_order['origin'],
          'email'           => vtex_order['clientProfileData']['email'],
          'placed_on'       => vtex_order['creationDate'],
          'totals' => {
                        'item'       => hash_total['Items'],
                        'adjustment' => adjustments,
                        'tax'        => hash_total['Tax'],
                        'shipping'   => hash_total['Shipping'],
                        'payment'    => total_order,
                        'order'      => total_order
                      },
          'line_items'  => parse_items(vtex_order),
          'adjustments' => [
            {
              'name'  => 'Tax',
              'value' => hash_total['Tax']
            },
            {
              'name'  => 'Discounts',
              'value' => hash_total['Discounts']
            },
            {
              'name'  => 'Shipping',
              'value' => hash_total['Shipping']
            }
          ],
          'shipping_address' => {
            'firstname' => vtex_order['clientProfileData']['firstName'],
            'lastname'  => vtex_order['clientProfileData']['lastName'],
            'address1'  => address1(vtex_order),
            'address2'  => address2(vtex_order),
            'zipcode'   => vtex_order['shippingData']['address']['postalCode'],
            'city'      => vtex_order['shippingData']['address']['city'],
            'state'     => vtex_order['shippingData']['address']['state'],
            'country'   => vtex_order['shippingData']['address']['country'],
            'phone'     => vtex_order['clientProfileData']['phone']
          },
          'billing_address' => {
            'firstname' => vtex_order['clientProfileData']['firstName'],
            'lastname'  => vtex_order['clientProfileData']['lastName'],
            'address1'  => address1(vtex_order),
            'address2'  => address2(vtex_order),
            'zipcode'   => vtex_order['shippingData']['address']['postalCode'],
            'city'      => vtex_order['shippingData']['address']['city'],
            'state'     => vtex_order['shippingData']['address']['state'],
            'country'   => vtex_order['shippingData']['address']['country'],
            'phone'     => vtex_order['clientProfileData']['phone']
          },
          'payments' => parse_payments(vtex_order)
        }
      end

      def parse_payments(vtex_order)
        payments = []
        (vtex_order['paymentData']['transactions'] || []).each do | transaction |
          (transaction['payments'] || []).map do |payment|
            payments << {
              'tranaction_id'  => transaction['transactionId'],
              'number'         => payment['installments'],
              'status'         => vtex_order['status'],
              'amount'         => payment['value'],
              'payment_method' => payment['paymentSystemName'],
              'due_date'       => payment['dueDate']
            }
          end
        end
        payments
      end

      def parse_items(vtex_order)
        (vtex_order['items'] || []).map do |item, |
          {
            'product_id' => item['productId'],
            'sku'        => item['sellerSku'],
            'square_id'  => item['id'],
            'name'       => item['name'],
            'quantity'   => item['quantity'],
            'price'      => item['price']
          }
        end
      end

      private

      def address1(vtex_order)
        "#{vtex_order['shippingData']['address']['street']}, #{vtex_order['shippingData']['address']['number']}"
      end

      def address2(vtex_order)
        "#{vtex_order['shippingData']['address']['neighborhood']} - #{vtex_order['shippingData']['address']['complement']}"
      end

      def build_hash_total(vtex_order)
        (vtex_order['totals'] || []).inject({}) do |acc, total|
          acc[total['id']] = total['value']
          acc
        end
      end
    end
  end
end
