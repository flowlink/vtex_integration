module Factories
  def self.product(sku = 'ROR-TS')
    {
      'id'          => sku,
      'name'        => "Ruby on Rails T-Shirt #{sku}",
      'description' => 'Some description text for the product.',
      'sku'         => sku,
      'price'       => 31,
      'created_at'  => '2014-02-03T19:00:54.386Z',
      'updated_at'  => '2014-02-03T19:22:54.386Z',
      'properties'  => {
        'fabric'=> 'cotton',
      },
      'options' => [ 'color', 'size' ],
      'class'   => 'Vendável',
      'brand'   => 'Rails Core',
      'family'  => 'Cats',
      'weight'  => '1.4',
      'height'  => '40',
      'width'   => '40',
      'length'  => '55',
      'taxons'=> [
        ['Clothes', 'T-Shirts'],
        ['Brands', 'Spree']
      ],
      'variants'=> [
        {
          'name' => 'Ruby on Rails T-Shirt S',
          'sku'  => "#{sku}-small",
          'price'       => 31,
          'options'=> {
            'size'  => 'small',
            'color' => 'white'
          },
          'abacos' => {
            'codigo_barras' => "code-#{sku}-1",
            'codigo_produto_abacos' => "#{sku}1"
          }
        },
        {
          'name' => 'Ruby on Rails T-Shirt M',
          'sku'  => "#{sku}-medium",
          'price'       => 30,
          'options'=> {
            'size'  => 'medium',
            'color' => 'black'
          },
          'abacos' => {
            'codigo_barras' => "code-#{sku}-2",
            'codigo_produto_abacos' => "#{sku}2"
          }
        }
      ],
      'specifications' => [
        {
          'name' => 'Composition',
          'value' => '100% Cottom'
        }
      ]
    }
  end
end
