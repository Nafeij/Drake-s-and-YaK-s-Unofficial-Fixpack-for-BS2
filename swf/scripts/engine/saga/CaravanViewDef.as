package engine.saga
{
   import engine.landscape.travel.def.CartDef;
   import flash.utils.Dictionary;
   
   public class CaravanViewDef
   {
       
      
      public var id:String;
      
      public var sprite_front:CaravanViewSpriteDef;
      
      public var sprite_narrator:CaravanViewSpriteDef;
      
      public var sprite_extra:CaravanViewSpriteDef;
      
      public var sprites_population:Vector.<CaravanViewSpriteDef>;
      
      public var sprites:Dictionary;
      
      public var allowRotation:Boolean = true;
      
      public var useAlternateSpline:Boolean;
      
      public var glow:CaravanViewGlowDef;
      
      public var cartDef:CartDef;
      
      public var alignFrontWithTravelPosition:Boolean;
      
      public function CaravanViewDef()
      {
         this.sprites_population = new Vector.<CaravanViewSpriteDef>();
         this.sprites = new Dictionary();
         super();
      }
      
      public static function ctorWorld(param1:Boolean, param2:Boolean, param3:Boolean = true, param4:Boolean = true, param5:Boolean = false) : CaravanViewDef
      {
         var _loc6_:CaravanViewDef = new CaravanViewDef();
         if(param2)
         {
            _loc6_.setGlow(CaravanViewGlowDef.ctorWorld());
         }
         if(param1)
         {
            _loc6_.setId("world_ships");
            _loc6_.addFront(new CaravanViewSpriteDef().init("caravan_ships_front","caravan_ships_front",0,0,0,false,1,0,0));
            _loc6_.addPop(new CaravanViewSpriteDef().init("caravan_ships2","caravan_ships2",0,0,0,false,0,96,-96).setPop(SagaVar.VAR_NUM_POPULATION,100,1,1));
            _loc6_.addPop(new CaravanViewSpriteDef().init("caravan_ships3","caravan_ships3",0,0,0,true,-1,500,-500).setPop(SagaVar.VAR_NUM_POPULATION,500,1,1));
            _loc6_.useAlternateSpline = true;
            _loc6_.allowRotation = false;
         }
         else
         {
            _loc6_.setId("world");
            if(param4)
            {
               _loc6_.addFront(new CaravanViewSpriteDef().init("world_cart_front","world_cart",0,28,7,false,-1,34,13));
            }
            _loc6_.addPop(new CaravanViewSpriteDef().init("world_caravan","world_caravan",0,20,20).setPop(SagaVar.VAR_NUM_POPULATION,100,0,30,param5));
            if(param3)
            {
               _loc6_.addPop(new CaravanViewSpriteDef().init("world_cart_pop","world_cart",0,28,7,false,1,26,0).setPop(SagaVar.VAR_NUM_POPULATION,500,0,10));
            }
         }
         return _loc6_;
      }
      
      public static function ctorClose(param1:Boolean, param2:Boolean, param3:Boolean, param4:CartDef) : CaravanViewDef
      {
         var _loc6_:Boolean = false;
         var _loc7_:Saga = null;
         var _loc5_:CaravanViewDef = new CaravanViewDef();
         _loc5_.alignFrontWithTravelPosition = !param2 && !param1;
         _loc5_.cartDef = param4;
         if(param3)
         {
            _loc5_.setGlow(CaravanViewGlowDef.ctorClose());
         }
         if(param2)
         {
            if(param4)
            {
               if(param4.hasYox)
               {
                  _loc5_.addFront(new CaravanViewSpriteDef().init("caravan_yox_front","caravan_yox",0,42,17,false,-1).setTrail("cart_2wheel_front"));
                  _loc5_.addSprite(new CaravanViewSpriteDef().init("cart_2wheel_front",param4.animId,0,param4.foot_lead,param4.foot_tail,false,-1).addCartDef(param4).setLead("caravan_yox_front"));
               }
               else
               {
                  _loc5_.addFront(new CaravanViewSpriteDef().init("cart_no_yox_front",param4.animId,0,param4.foot_lead,param4.foot_tail,false,-1).addCartDef(param4));
               }
            }
            else
            {
               _loc5_.addFront(new CaravanViewSpriteDef().init("caravan_yox_front","caravan_yox",0,42,17,false,-1).setTrail("cart_2wheel_front"));
               _loc5_.addSprite(new CaravanViewSpriteDef().init("cart_2wheel_front","cart_2wheel",0,84,70,false,-1).setLead("caravan_yox_front"));
            }
         }
         if(param1)
         {
            _loc5_.setId("close");
            _loc7_ = Saga.instance;
            _loc6_ = Boolean(_loc7_) && _loc7_.def.id == "saga2";
            if(_loc6_)
            {
               _loc5_.addExtra(new CaravanViewSpriteDef().init("caravan_yox_extra","caravan_yox",0,42,17,false,-1).setTrail("cart_bellower"));
               _loc5_.addSprite(new CaravanViewSpriteDef().init("cart_bellower","cart_bellower",0,84,70,false,-1).setLead("caravan_yox_extra"));
            }
            _loc5_.addNarrator(new CaravanViewSpriteDef().init("caravan_yox_narrator","caravan_yox",0,42,17,false,-1).setTrail("cart_armored"));
            _loc5_.addSprite(new CaravanViewSpriteDef().init("cart_armored","cart_armored",0,84,70,false,-1).setLead("caravan_yox_narrator"));
            _loc5_.addSprite(new CaravanViewSpriteDef().init("cart_2wheel_pop","cart_2wheel",0,84,70,false,1,84,-35).setLead("caravan_yox_pop"));
         }
         else
         {
            _loc5_.setId("close_noyoxen");
         }
         _loc5_.addPop(new CaravanViewSpriteDef().init("group_varl","group_varl",3,77,77).setPop(SagaVar.VAR_NUM_VARL,20,0,20));
         _loc5_.addPop(new CaravanViewSpriteDef().init("group_fighter","group_fighter",3,70,70).setPop(SagaVar.VAR_NUM_FIGHTERS,20,0,20));
         _loc5_.addPop(new CaravanViewSpriteDef().init("group_peasant","group_peasant",3,70,70).setPop(SagaVar.VAR_NUM_PEASANTS,20,0,40));
         if(param1)
         {
            _loc5_.addPop(new CaravanViewSpriteDef().init("caravan_yox_pop","caravan_yox",0,42,17,false,0,21,17).setPop(SagaVar.VAR_NUM_POPULATION,60,0,10).setTrail("cart_2wheel_pop"));
         }
         return _loc5_;
      }
      
      public function setId(param1:String) : CaravanViewDef
      {
         this.id = param1;
         return this;
      }
      
      public function setGlow(param1:CaravanViewGlowDef) : CaravanViewGlowDef
      {
         this.glow = param1;
         return param1;
      }
      
      public function addSprite(param1:CaravanViewSpriteDef) : CaravanViewSpriteDef
      {
         this.sprites[param1.type] = param1;
         return param1;
      }
      
      public function addFront(param1:CaravanViewSpriteDef) : CaravanViewSpriteDef
      {
         this.addSprite(param1);
         this.sprite_front = param1;
         return param1;
      }
      
      public function addNarrator(param1:CaravanViewSpriteDef) : CaravanViewSpriteDef
      {
         this.addSprite(param1);
         this.sprite_narrator = param1;
         return param1;
      }
      
      public function addExtra(param1:CaravanViewSpriteDef) : CaravanViewSpriteDef
      {
         this.addSprite(param1);
         this.sprite_extra = param1;
         return param1;
      }
      
      public function addPop(param1:CaravanViewSpriteDef) : CaravanViewSpriteDef
      {
         this.addSprite(param1);
         this.sprites_population.push(param1);
         return param1;
      }
   }
}
