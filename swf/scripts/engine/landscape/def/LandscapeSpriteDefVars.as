package engine.landscape.def
{
   import engine.anim.def.AnimLibrary;
   import engine.anim.view.ColorPulsatorDef;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   import engine.def.RectangleVars;
   import engine.landscape.travel.def.LandscapeParamDef;
   import flash.utils.Dictionary;
   
   public class LandscapeSpriteDefVars extends LandscapeSpriteDef
   {
      
      public static var MAX_DIMENSION:int = 2048;
      
      public static const schema:Object = {
         "name":"LandscapeLayerSpriteDefVars",
         "type":"object",
         "properties":{
            "nameId":{"type":"string"},
            "offset":{
               "type":PointVars.schema,
               "optional":true
            },
            "scale":{
               "type":PointVars.schema,
               "optional":true
            },
            "rotation":{
               "type":"number",
               "optional":true
            },
            "bmp":{
               "type":"string",
               "optional":true
            },
            "anim":{
               "type":"string",
               "optional":true
            },
            "clickable":{
               "type":"boolean",
               "optional":true
            },
            "hover":{
               "type":"string",
               "optional":true
            },
            "help":{
               "type":"boolean",
               "optional":true
            },
            "label":{
               "type":"string",
               "optional":true
            },
            "labelOffset":{
               "type":PointVars.schema,
               "optional":true
            },
            "blendMode":{
               "type":"string",
               "optional":true
            },
            "smoothing":{
               "type":"boolean",
               "optional":true
            },
            "guidepost":{
               "type":"string",
               "optional":true
            },
            "anim_path":{
               "type":LandscapeAnimPathDefVars.schema,
               "optional":true
            },
            "debug":{
               "type":"boolean",
               "optional":true
            },
            "happening":{
               "type":"string",
               "optional":true
            },
            "anchor":{
               "type":"boolean",
               "optional":true
            },
            "autoplay":{
               "type":"boolean",
               "optional":true
            },
            "loops":{
               "type":"number",
               "optional":true
            },
            "visible":{
               "type":"boolean",
               "optional":true
            },
            "popin":{
               "type":"boolean",
               "optional":true
            },
            "frame":{
               "type":"number",
               "optional":true
            },
            "frameVar":{
               "type":"string",
               "optional":true
            },
            "ifCondition":{
               "type":"string",
               "optional":true
            },
            "localrect":{
               "type":RectangleVars.schema,
               "optional":true
            },
            "landscapeParams":{
               "type":"array",
               "items":LandscapeParamDef.schema,
               "optional":true
            },
            "colorPulse":{
               "type":ColorPulsatorDef.schema,
               "optional":true
            },
            "langs":{
               "type":"string",
               "optional":true
            },
            "linked":{
               "type":"string",
               "optional":true
            },
            "tooltip":{
               "type":LandscapeClickableTooltipDef.schema,
               "optional":true
            }
         }
      };
      
      private static var lg:Boolean;
       
      
      public function LandscapeSpriteDefVars(param1:LandscapeLayerDef, param2:String, param3:Object, param4:ILogger, param5:AnimLibrary)
      {
         var _loc6_:Object = null;
         var _loc7_:LandscapeParamDef = null;
         super(param1);
         EngineJsonDef.validateThrow(param3,schema,param4);
         nameId = param3.nameId;
         if(param3.colorPulse != undefined)
         {
            colorPulse = new ColorPulsatorDef().fromJson(param3.colorPulse,param4);
         }
         if(param3.offset != undefined)
         {
            _offset = PointVars.parse(param3.offset,param4,_offset);
         }
         if(param3.scale != undefined)
         {
            _scale = PointVars.parse(param3.scale,param4,_scale);
         }
         if(param3.rotation != undefined)
         {
            rotation = param3.rotation;
         }
         langs = param3.langs;
         this.parseLangs();
         if(param3.landscapeParams)
         {
            landscapeParams = new Vector.<LandscapeParamDef>();
            for each(_loc6_ in param3.landscapeParams)
            {
               _loc7_ = new LandscapeParamDef().fromJson(_loc6_,param4);
               landscapeParams.push(_loc7_);
            }
         }
         ifCondition = param3.ifCondition;
         bmp = param3.bmp;
         autoplay = BooleanVars.parse(param3.autoplay,autoplay);
         visible = BooleanVars.parse(param3.visible,visible);
         popin = BooleanVars.parse(param3.popin,popin);
         clickable = BooleanVars.parse(param3.clickable);
         hover = param3.hover;
         help = BooleanVars.parse(param3.help);
         label = param3.label;
         blendMode = param3.blendMode;
         smoothing = BooleanVars.parse(param3.smoothing,smoothing);
         guidepost = param3.guidepost;
         anchor = BooleanVars.parse(param3.anchor,anchor);
         linkedId = param3.linked;
         if(Boolean(bmp) || !clickable)
         {
            localrect = RectangleVars.parse(param3.localrect,param4,localrect);
         }
         if(localrect)
         {
            if(bmp)
            {
               if(MAX_DIMENSION > 0)
               {
                  if(localrect.width > MAX_DIMENSION || localrect.height > MAX_DIMENSION)
                  {
                     param4.error("Scene sprite [" + bmp + "] too large (" + localrect.width + " x " + localrect.height + ") scene [" + param2 + "]");
                  }
               }
            }
         }
         if(param3.frame != undefined)
         {
            frame = param3.frame;
         }
         if(param3.frameVar != undefined)
         {
            frameVar = param3.frameVar;
         }
         if(param3.loops != undefined)
         {
            loops = param3.loops;
         }
         if(param3.labelOffset)
         {
            labelOffset = PointVars.parse(param3.labelOffset,param4,labelOffset);
         }
         if(param3.anim)
         {
            anim = param3.anim;
         }
         if(anim)
         {
            this.localrect.x = Math.floor(this.localrect.x);
            this.localrect.y = Math.floor(this.localrect.y);
            this.localrect.width = Math.ceil(this.localrect.width);
            this.localrect.height = Math.ceil(this.localrect.height);
         }
         if(param3.anim_path)
         {
            animPath = new LandscapeAnimPathDefVars(this,param3.anim_path,param4);
         }
         debug = BooleanVars.parse(param3.debug);
         happening = param3.happening;
         if(param3.tooltip)
         {
            tooltip = new LandscapeClickableTooltipDef(this).fromJson(param3.tooltip,param4);
         }
      }
      
      public static function save(param1:LandscapeSpriteDef) : Object
      {
         var _loc3_:LandscapeParamDef = null;
         var _loc2_:Object = {"nameId":param1.nameId};
         if(param1.bmp)
         {
            _loc2_.bmp = param1.bmp;
         }
         if(param1.langs)
         {
            _loc2_.langs = param1.langs;
         }
         if(Boolean(param1._offset) && (param1._offset.x != 0 || param1._offset.y != 0))
         {
            _loc2_.offset = PointVars.save(param1._offset);
         }
         if(param1.rotation != 0)
         {
            _loc2_.rotation = param1.rotation;
         }
         if(Boolean(param1._scale) && (param1._scale.x != 1 || param1._scale.y != 1))
         {
            _loc2_.scale = PointVars.save(param1._scale);
         }
         if(param1.anim)
         {
            _loc2_.anim = param1.anim;
         }
         if(param1.hover)
         {
            _loc2_.hover = param1.hover;
         }
         if(param1.clickable)
         {
            _loc2_.clickable = true;
         }
         if(param1.help)
         {
            _loc2_.help = true;
         }
         if(param1.frame >= 0)
         {
            _loc2_.frame = param1.frame;
         }
         if(param1.frameVar)
         {
            _loc2_.frameVar = param1.frameVar;
         }
         if(param1.label)
         {
            _loc2_.label = param1.label;
            if(Boolean(param1.labelOffset) && (param1.labelOffset.x != 0 || param1.labelOffset.y != 0))
            {
               _loc2_.labelOffset = PointVars.save(param1.labelOffset);
            }
         }
         if(param1.blendMode)
         {
            _loc2_.blendMode = param1.blendMode;
         }
         if(param1.guidepost)
         {
            _loc2_.guidepost = param1.guidepost;
         }
         if(param1.animPath)
         {
            _loc2_.anim_path = LandscapeAnimPathDefVars.save(param1.animPath);
         }
         if(param1.debug)
         {
            _loc2_.debug = true;
         }
         if(param1.smoothing)
         {
            _loc2_.smoothing = true;
         }
         if(param1.happening)
         {
            _loc2_.happening = param1.happening;
         }
         if(param1.anchor)
         {
            _loc2_.anchor = param1.anchor;
         }
         if(param1.popin)
         {
            _loc2_.popin = param1.popin;
         }
         if(!param1.autoplay)
         {
            _loc2_.autoplay = param1.autoplay;
         }
         if(!param1.visible)
         {
            _loc2_.visible = param1.visible;
         }
         if(param1.loops)
         {
            _loc2_.loops = param1.loops;
         }
         if(!param1.localrect.isEmpty())
         {
            if(param1.anim)
            {
               param1.localrect.x = int(param1.localrect.x);
               param1.localrect.y = int(param1.localrect.y);
               param1.localrect.width = int(param1.localrect.width);
               param1.localrect.height = int(param1.localrect.height);
            }
            _loc2_.localrect = RectangleVars.save(param1.localrect);
         }
         if(Boolean(param1.landscapeParams) && Boolean(param1.landscapeParams.length))
         {
            _loc2_.landscapeParams = [];
            for each(_loc3_ in param1.landscapeParams)
            {
               _loc2_.landscapeParams.push(_loc3_.toJson());
            }
         }
         if(param1.ifCondition)
         {
            _loc2_.ifCondition = param1.ifCondition;
         }
         if(param1.colorPulse)
         {
            _loc2_.colorPulse = param1.colorPulse.toJson();
         }
         if(param1.linkedId)
         {
            _loc2_.linked = param1.linkedId;
         }
         if(param1.tooltip)
         {
            _loc2_.tooltip = param1.tooltip.toJson();
         }
         return _loc2_;
      }
      
      private function parseLangs() : void
      {
         var _loc2_:String = null;
         if(!langs)
         {
            langsDict = null;
            return;
         }
         langsDict = new Dictionary();
         var _loc1_:Array = langs.split(",");
         for each(_loc2_ in _loc1_)
         {
            langsDict[_loc2_] = true;
         }
      }
   }
}
