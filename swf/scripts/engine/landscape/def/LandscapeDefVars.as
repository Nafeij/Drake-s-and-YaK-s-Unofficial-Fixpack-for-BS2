package engine.landscape.def
{
   import engine.anim.def.AnimLibrary;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.RectangleVars;
   import engine.landscape.travel.def.ITravelDef;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.travel.def.TravelDefVars;
   import engine.scene.def.SceneDef;
   
   public class LandscapeDefVars extends LandscapeDef
   {
      
      public static const schema:Object = {
         "name":"LandscapeDefVars",
         "type":"object",
         "properties":{
            "layers":{
               "type":"array",
               "items":LandscapeLayerDefVars.schema
            },
            "boundary":{"type":RectangleVars.schema},
            "hasFog":{
               "type":"boolean",
               "optional":true
            },
            "highQuality":{
               "type":"boolean",
               "optional":true
            },
            "fogColor":{
               "type":"number",
               "optional":true
            },
            "fogAlpha":{
               "type":"number",
               "optional":true
            },
            "travel":{
               "type":TravelDefVars.schema,
               "optional":true
            },
            "travels":{
               "type":"array",
               "items":TravelDefVars.schema,
               "optional":true
            }
         }
      };
       
      
      public function LandscapeDefVars(param1:SceneDef, param2:Object, param3:ILogger, param4:AnimLibrary)
      {
         var errors:int;
         var layerNumber:int = 0;
         var layerv:Object = null;
         var layer:LandscapeLayerDefVars = null;
         var travel:TravelDef = null;
         var tdv:Object = null;
         var sceneDef:SceneDef = param1;
         var vars:Object = param2;
         var logger:ILogger = param3;
         var anims:AnimLibrary = param4;
         super(sceneDef);
         if(!vars)
         {
            throw new ArgumentError("Null landscape for " + sceneDef.name);
         }
         EngineJsonDef.validateThrow(vars,schema,logger);
         ;
         maxSpeed = 0;
         errors = 0;
         var _loc6_:int = 0;
         var _loc7_:* = vars.layers;
         for(; §§hasnext(_loc7_,_loc6_); layerNumber++)
         {
            layerv = §§nextvalue(_loc6_,_loc7_);
            try
            {
               layer = new LandscapeLayerDefVars(this);
               layer.fromJson(sceneDef.name,layerv,logger,anims);
               maxSpeed = Math.max(maxSpeed,layer.speed);
               layers.push(layer);
               if(layer.hasTooltips)
               {
                  hasTooltips = true;
               }
            }
            catch(e:Error)
            {
               logger.error("LandscapeDefVars Failed to load layer " + layerNumber);
               logger.error(e.getStackTrace());
               errors++;
               continue;
            }
         }
         resolveLayers();
         boundary = RectangleVars.parse(vars.boundary,logger,boundary);
         highQuality = BooleanVars.parse(vars.highQuality,highQuality);
         if(vars.hasFog != undefined)
         {
            this.hasFog = BooleanVars.parse(vars.hasFog);
         }
         if(vars.fogColor != undefined)
         {
            this.fogColor = vars.fogColor;
         }
         if(vars.fogAlpha != undefined)
         {
            this.fogAlpha = vars.fogAlpha;
         }
         if(vars.travel != undefined)
         {
            travel = new TravelDefVars(this,vars.travel,logger);
            travels = new Vector.<ITravelDef>();
            travels.push(travel);
            if(!travel.id)
            {
               travel.id = "travel_" + travels.length.toString();
            }
         }
         if(vars.travels)
         {
            travels = new Vector.<ITravelDef>();
            for each(tdv in vars.travels)
            {
               travel = new TravelDefVars(this,tdv,logger);
               travels.push(travel);
               if(!travel.id)
               {
                  travel.id = "travel_" + travels.length.toString();
               }
            }
         }
         if(errors)
         {
            throw new ArgumentError("LandscapeDefVars errors loading.");
         }
      }
      
      public static function save(param1:LandscapeDef) : Object
      {
         var _loc4_:LandscapeLayerDef = null;
         var _loc5_:TravelDef = null;
         var _loc2_:Object = {};
         _loc2_.layers = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1.numLayerDefs)
         {
            _loc4_ = param1.getLayerDef(_loc3_) as LandscapeLayerDef;
            _loc2_.layers.push(LandscapeLayerDefVars.save(_loc4_));
            _loc3_++;
         }
         _loc2_.boundary = RectangleVars.save(param1.boundary);
         if(param1.travels)
         {
            _loc2_.travels = [];
            for each(_loc5_ in param1.travels)
            {
               _loc2_.travels.push(TravelDefVars.save(_loc5_));
            }
         }
         if(param1.highQuality)
         {
            _loc2_.highQuality = param1.highQuality;
         }
         return _loc2_;
      }
   }
}
