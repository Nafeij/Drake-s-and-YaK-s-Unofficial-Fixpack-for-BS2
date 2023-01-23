package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   import flash.geom.Rectangle;
   
   public class TravelReactorDef
   {
      
      public static const schema:Object = {
         "name":"TravelReactorDef",
         "type":"object",
         "properties":{"id":{"type":"string"}}
      };
       
      
      public var id:String;
      
      public var spawnLead:int;
      
      public var spawnDurationMs:int;
      
      public var spawnOffsetY:Number = 0;
      
      public var spawnWidth:int;
      
      public var riserRects:Vector.<Rectangle>;
      
      public var fallDebris:Vector.<Rectangle>;
      
      public var crashDust:Vector.<Rectangle>;
      
      public var fallPeople:Vector.<Rectangle>;
      
      public var fallCarts:Vector.<Rectangle>;
      
      public var spawnMargin:int = 4;
      
      public var spawnMarginPercent:Number = 0.1;
      
      public var spawnUrl:String;
      
      public var reachSoundEvent:String;
      
      public var fallSoundEvent:String;
      
      public var landSoundEvent:String;
      
      public var splineHeightDelta:Number = -2;
      
      public var splineStart:Number = 0;
      
      public var splineStart_t:Number = 0;
      
      public var splineEnd:Number = 0;
      
      public function TravelReactorDef()
      {
         this.riserRects = new Vector.<Rectangle>();
         this.fallDebris = new Vector.<Rectangle>();
         this.crashDust = new Vector.<Rectangle>();
         this.fallPeople = new Vector.<Rectangle>();
         this.fallCarts = new Vector.<Rectangle>();
         super();
         this.spawnLead = 0;
         this.spawnDurationMs = 10000;
         this.spawnOffsetY = 650;
         this.spawnUrl = "saga2/scene/world/wld_ormsachasm/magic_bridge_atlas.png";
         this.riserRects.push(new Rectangle(0,0,162,121));
         this.riserRects.push(new Rectangle(164,0,42,64));
         this.riserRects.push(new Rectangle(208,0,30,19));
         this.riserRects.push(new Rectangle(190,66,67,27));
         this.riserRects.push(new Rectangle(167,94,90,73));
         this.riserRects.push(new Rectangle(278,0,24,11));
         this.riserRects.push(new Rectangle(306,0,39,32));
         this.riserRects.push(new Rectangle(348,0,160,78));
         this.riserRects.push(new Rectangle(260,66,55,19));
         this.riserRects.push(new Rectangle(260,94,86,47));
         this.riserRects.push(new Rectangle(355,94,136,63));
         this.riserRects.push(new Rectangle(260,153,24,15));
         this.riserRects.push(new Rectangle(286,154,21,13));
         this.fallDebris.push(new Rectangle(87,123,77,133));
         this.fallDebris.push(new Rectangle(14,127,50,104));
         this.fallDebris.push(null);
         this.fallDebris.push(new Rectangle(14,127,50,104));
         this.fallDebris.push(new Rectangle(87,123,77,133));
         this.fallDebris.push(null);
         this.fallDebris.push(null);
         this.fallDebris.push(new Rectangle(87,123,77,133));
         this.fallDebris.push(new Rectangle(14,127,50,104));
         this.fallDebris.push(new Rectangle(14,127,50,104));
         this.fallDebris.push(new Rectangle(87,123,77,133));
         this.fallDebris.push(null);
         this.fallDebris.push(null);
         this.fallPeople.push(new Rectangle(206,169,9,14));
         this.fallPeople.push(new Rectangle(220,169,7,15));
         this.fallPeople.push(new Rectangle(230,169,13,15));
         this.fallPeople.push(new Rectangle(247,169,6,14));
         this.fallCarts.push(new Rectangle(228,186,30,21));
         this.fallCarts.push(new Rectangle(244,209,12,10));
         this.fallCarts.push(new Rectangle(213,221,43,27));
         this.reachSoundEvent = "world/saga2_amb/tbs2_amb_magic_bridge_connect";
         this.fallSoundEvent = "world/saga2_amb/tbs2_amb_magic_bridge_fall";
         this.landSoundEvent = "world/saga2_amb/tbs2_amb_magic_bridge_crash";
         this.spawnMargin = 4;
         this.spawnMarginPercent = 0.05;
         this.splineStart = 850;
         this.splineEnd = 4340;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : TravelReactorDef
      {
         this.id = param1.id;
         return this;
      }
      
      public function toJson() : Object
      {
         return {"id":(!!this.id ? this.id : "")};
      }
   }
}
