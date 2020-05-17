class Gilbert < Chingu::GameObject
  trait :bounding_box, debug: true, scale: 0.35
  traits :velocity, :timer, :collision_detection
  attr_accessor :jumping
  def initialize(options)
    super
    self.input = {holding_left: :izquierda, holding_right: :derecha, [:space, :holding_up] => :arriba, z: :corriendo, released_z: :no_corriendo}
    @gilbertAnimations = {}
    @gilbertAnimations[:run_right] = Animation.new(file: 'media/Gilbert_animacion_derecha2.png', size: [66, 103])
    @gilbertAnimations[:run_right].frame_names = {stand_right: 15..15}
    @gilbertAnimations[:run_left] = Animation.new(file: 'media/Gilbert_animacion_izquierda2.png', size: [66,103])
    @gilbertAnimations[:run_left].frame_names = {stand_left: 15..15}
    @animation = @gilbertAnimations[:run_right][:stand_right]
    @direcction = :stand_right
    @orientation = :run_right
    @jumping = false
    @corriendo = false
    @speed = 3

    self.scale = 1
    self.acceleration_y = 0.5
    self.max_velocity = 15
    self.rotation_center = :bottom_center #Lo que hace que no se caiga. Super importante. Mega iMPORTANTE

    update
    cache_bounding_box
  end

  def izquierda
    move(-@speed, 0)
    @animation = @gilbertAnimations[:run_left]
    @orientation = :run_left
    @direcction = :stand_left
  end
  def derecha
    move(@speed, 0)
    @animation = @gilbertAnimations[:run_right]
    @orientation = :run_right
    @direcction = :stand_right
  end
  def arriba
    return if @jumping
    @jumping = true
    @corriendo ? self.velocity_y = -13 : self.velocity_y = -10
  end

  def corriendo
    @speed = 5
    @corriendo = true
  end

  def no_corriendo
    @speed = 3
    @corriendo = false
  end

#Este metodo es la base primordial de todo
  def move(x,y)
    self.x += x
    self.each_collision(Base, Plataforma) do |gilbert, superficie|
      self.x = previous_x
      break
    end
    self.y += y
  end

  def update
    @image = @animation.next!
    if @x <= 0
      @x = @last_x
      @y = @last_y
    end

    #Esto es Gloria :'''v
    self.each_collision(Base, Plataforma) do |gilbert, superficie|
      if self.velocity_y < 0
        gilbert.y = superficie.bb.bottom + gilbert.image.height * self.factor_y
        self.velocity_y = 0
      else
        @jumping = false        
        gilbert.y = superficie.bb.top - 1
      end
    end

    @animation = @gilbertAnimations[@orientation][@direcction] unless moved?
    @last_x, @last_y = @x, @y

    puts @speed
  end
end