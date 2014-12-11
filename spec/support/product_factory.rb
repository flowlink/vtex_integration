module Factories
  def self.product(sku = 'ROR-TS')
    {
      'id'          => '12345',
      'name'        => 'Ruby on Rails T-Shirt',
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
      'images' => [
        {
          'url'      => 'http://dummyimage.com/600x400/000/fff.jpg&text=Spree T-Shirt',
          'position' => 1,
          'title'    => 'Spree T-Shirt - Grey Small',
          'type'     => 'thumbnail',
          'dimensions'=> {
            'height' => 220,
            'width'  => 100
          }
        }
      ],
      'variants'=> [
        {
          'name' => 'Ruby on Rails T-Shirt S',
          'sku'  => '#{sku}-small',
          'price'       => 31,
          'options'=> {
            'size'  => 'small',
            'color' => 'white'
          },
          'images' => [
            {
              'url'      => 'http://dummyimage.com/600x400/000/fff.jpg&text=Spree T-Shirt',
              'position' => 1,
              'title'    => 'Spree T-Shirt - Grey Small',
              'type'     => 'thumbnail',
              'dimensions'=> {
                'height' => 220,
                'width'  => 100
              }
            }
          ]
        },
        {
          'name' => 'Ruby on Rails T-Shirt M',
          'sku'  => '#{sku}-medium',
          'price'       => 30,
          'options'=> {
            'size'  => 'medium',
            'color' => 'black'
          },
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
