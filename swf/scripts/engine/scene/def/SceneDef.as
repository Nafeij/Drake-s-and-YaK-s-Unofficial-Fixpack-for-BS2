package engine.scene.def
{
   import engine.anim.def.AnimLibrary;
   import engine.battle.board.def.BattleBoardDef;
   import engine.battle.board.def.BattleBoardTipsDef;
   import engine.battle.music.BattleMusicDef;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.landscape.def.ILandscapeDef;
   import engine.landscape.def.LandscapeDef;
   import engine.landscape.travel.def.ITravelDef;
   import engine.landscape.travel.def.ITravelLocationDef;
   import engine.landscape.travel.def.TravelDef;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.HappeningDefBag;
   import engine.saga.happening.IHappeningDefProvider;
   import engine.sound.def.SoundLibrary;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class SceneDef extends EventDispatcher implements ISceneDef
   {
      
      public static const EVENT_BOARDS:String = "SceneDef.EVENT_BOARDS";
      
      public static const EVENT_CAMERA_ANCHOR:String = "SceneDef.EVENT_CAMERA_ANCHOR";
      
      public static const EVENT_CAMERA_START:String = "SceneDef.EVENT_CAMERA_START";
      
      public static const EVENT_AUDIO:String = "SceneDef.EVENT_AUDIO";
      
      public static const EVENT_BATTLE_MUSIC:String = "SceneDef.EVENT_BATTLE_MUSIC";
       
      
      public var _id:String;
      
      private var _url:String;
      
      public var loadedJson:String;
      
      public var _landscape:LandscapeDef;
      
      public var boards:Vector.<BattleBoardDef>;
      
      public var splines;
      
      public var battleScenarios;
      
      public var soundLibrary:SoundLibrary;
      
      public var killMusic:Boolean;
      
      public var xmusic:String;
      
      public var music:BattleMusicDef;
      
      public var anims:AnimLibrary;
      
      protected var _cameraStart:Point;
      
      protected var _cameraAnchor:Point;
      
      public var _cameraAnchorOnce:Boolean;
      
      public var cameraAnchorSpeed:Number = 1000;
      
      public var cameraDrift:Number = 4;
      
      public var inputDisabled:Boolean = false;
      
      public var tiltDisabled:Boolean = false;
      
      public var showTrainingExitButton:Boolean;
      
      public var cameraMinWidth:Number = 2048;
      
      public var cameraMaxWidth:Number = 2730.6666666666665;
      
      public var cameraMinHeight:Number = 1161.9858156028367;
      
      public var cameraMaxHeight:Number = 2730.6666666666665;
      
      public var cinemascope:Boolean;
      
      public var reverb:String;
      
      public var tutorial:String;
      
      public var happenings:HappeningDefBag;
      
      public var name:String;
      
      private var _audio:SceneAudioDef;
      
      private var _battleMusic:BattleMusicDef;
      
      public var loadAudio:Boolean;
      
      public var loadBattleMusic:Boolean;
      
      public var hideBannerButton:Boolean;
      
      public var hideHelpButton:Boolean;
      
      public var weatherDisabled:Boolean;
      
      public var disableAdjustBoundary:Boolean;
      
      public var tips:BattleBoardTipsDef;
      
      public var legacy_happenings:Boolean;
      
      public var split_happenings:Boolean;
      
      public var _audioUrl:String;
      
      public var _battleMusicUrl:String;
      
      public function SceneDef(param1:String)
      {
         this.boards = new Vector.<BattleBoardDef>();
         super();
         this.name = StringUtil.getBasename(param1);
         this.happenings = new HappeningDefBag(param1,this);
      }
      
      public function cleanup() : void
      {
         var _loc1_:BattleBoardDef = null;
         if(this._landscape)
         {
            this._landscape.cleanup();
            this._landscape = null;
         }
         this.battleMusic = null;
         this.happenings = null;
         this._audio = null;
         if(this.boards)
         {
            for each(_loc1_ in this.boards)
            {
               _loc1_.cleanup();
            }
            this.boards = null;
         }
         this.soundLibrary = null;
         this.tips = null;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
         if(this._url)
         {
            this._id = StringUtil.getBasename(this._url);
         }
         else
         {
            this._id = null;
         }
      }
      
      public function get audioUrl() : String
      {
         if(this._audioUrl)
         {
            return this._audioUrl;
         }
         var _loc1_:String = this.url.replace(".json",".audio.json");
         if(_loc1_.indexOf("saga2s") >= 0)
         {
            _loc1_ = _loc1_.replace("saga2s","saga2");
            this._audioUrl = _loc1_;
         }
         return _loc1_;
      }
      
      public function set audioUrl(param1:String) : void
      {
         this._audioUrl = param1;
         if(this._audioUrl)
         {
            this.loadAudio = true;
         }
      }
      
      public function get battleMusicUrl() : String
      {
         if(this._battleMusicUrl)
         {
            return this._battleMusicUrl;
         }
         var _loc1_:String = this.url.replace(".json",".btlmusic.json");
         if(_loc1_.indexOf("saga2s") >= 0)
         {
            _loc1_ = _loc1_.replace("saga2s","saga2");
            this._battleMusicUrl = _loc1_;
         }
         return _loc1_;
      }
      
      public function set battleMusicUrl(param1:String) : void
      {
         this._battleMusicUrl = param1;
         if(this._battleMusicUrl)
         {
            this.loadBattleMusic = true;
         }
      }
      
      public function get boundary() : Rectangle
      {
         if(this.landscape)
         {
            return this.landscape.boundary;
         }
         return new Rectangle();
      }
      
      public function getBoard(param1:String) : BattleBoardDef
      {
         var _loc2_:BattleBoardDef = null;
         for each(_loc2_ in this.boards)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function createBoardName(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < 100)
         {
            _loc3_ = param1 + _loc2_;
            if(!this.getBoard(_loc3_))
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function createBoard(param1:Locale) : BattleBoardDef
      {
         var _loc3_:BattleBoardDef = null;
         var _loc2_:String = this.createBoardName("New Board ");
         if(_loc2_)
         {
            _loc3_ = new BattleBoardDef(this);
            _loc3_.id = _loc2_;
            _loc3_.init();
            this.boards.push(_loc3_);
            dispatchEvent(new Event(EVENT_BOARDS));
            return _loc3_;
         }
         return null;
      }
      
      public function cloneBoard(param1:BattleBoardDef) : BattleBoardDef
      {
         var _loc3_:BattleBoardDef = null;
         var _loc2_:String = this.createBoardName(param1.id + "_");
         if(_loc2_)
         {
            _loc3_ = param1.clone();
            _loc3_.id = _loc2_;
            this.boards.push(_loc3_);
            dispatchEvent(new Event(EVENT_BOARDS));
            return _loc3_;
         }
         return null;
      }
      
      public function promoteBoard(param1:BattleBoardDef) : void
      {
         var _loc2_:int = this.boards.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.boards.splice(_loc2_,1);
            this.boards.splice(_loc2_ - 1,0,param1);
            dispatchEvent(new Event(EVENT_BOARDS));
         }
      }
      
      public function demoteBoard(param1:BattleBoardDef) : void
      {
         var _loc2_:int = this.boards.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.boards.length - 1)
         {
            this.boards.splice(_loc2_,1);
            this.boards.splice(_loc2_ + 1,0,param1);
            dispatchEvent(new Event(EVENT_BOARDS));
         }
      }
      
      public function removeBoard(param1:BattleBoardDef) : void
      {
         var _loc2_:int = this.boards.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.boards.splice(_loc2_,1);
            dispatchEvent(new Event(EVENT_BOARDS));
         }
      }
      
      public function get cameraAnchor() : Point
      {
         return this._cameraAnchor;
      }
      
      public function set cameraAnchor(param1:Point) : void
      {
         if(this._cameraAnchor == param1)
         {
            return;
         }
         this._cameraAnchor = param1;
         dispatchEvent(new Event(EVENT_CAMERA_ANCHOR));
      }
      
      public function get cameraStart() : Point
      {
         return this._cameraStart;
      }
      
      public function set cameraStart(param1:Point) : void
      {
         if(this._cameraStart == param1)
         {
            return;
         }
         this._cameraStart = param1;
         dispatchEvent(new Event(EVENT_CAMERA_START));
      }
      
      public function get audio() : SceneAudioDef
      {
         return this._audio;
      }
      
      public function set audio(param1:SceneAudioDef) : void
      {
         this._audio = param1;
         dispatchEvent(new Event(EVENT_AUDIO));
      }
      
      public function get battleMusic() : BattleMusicDef
      {
         return this._battleMusic;
      }
      
      public function set battleMusic(param1:BattleMusicDef) : void
      {
         if(this._battleMusic == param1)
         {
            return;
         }
         if(this._battleMusic)
         {
            this._battleMusic.cleanup();
         }
         this._battleMusic = param1;
         dispatchEvent(new Event(EVENT_BATTLE_MUSIC));
      }
      
      public function computeBattleBoardBoundary() : Rectangle
      {
         var _loc2_:BattleBoardDef = null;
         var _loc3_:Rectangle = null;
         var _loc1_:Rectangle = new Rectangle();
         for each(_loc2_ in this.boards)
         {
            _loc3_ = _loc2_.computeBoundary();
            _loc1_ = _loc1_.union(_loc3_);
         }
         return _loc1_;
      }
      
      public function cropToBoundary(param1:ILogger) : Dictionary
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         var _loc2_:String = StringUtil.stripSuffix(this.url,".json.z");
         var _loc3_:Dictionary = this.landscape.cropToBoundary(_loc2_,this.cameraMinWidth,this.cameraMinHeight,this.cameraMaxWidth,this.cameraMaxHeight);
         if(param1)
         {
            _loc4_ = 0;
            for each(_loc5_ in _loc3_)
            {
               _loc7_ = int(_loc5_.savings);
               _loc4_ += _loc7_;
            }
            _loc6_ = _loc4_ * 4 >> 20;
            param1.info("CropToBoundary removed " + _loc7_ + " pixels, " + _loc6_ + " MB");
         }
         return _loc3_;
      }
      
      public function reduceTextures(param1:Number, param2:ILogger) : Dictionary
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:* = 0;
         var _loc8_:int = 0;
         var _loc3_:String = StringUtil.stripSuffix(this.url,".json.z");
         var _loc4_:Dictionary = this.landscape.reduceTextures(_loc3_,param1);
         if(param2)
         {
            _loc5_ = 0;
            for each(_loc6_ in _loc4_)
            {
               _loc8_ = int(_loc6_.savings);
               _loc5_ += _loc8_;
            }
            _loc7_ = _loc5_ * 4 >> 20;
            param2.info("reduceTextures removed " + _loc8_ + " pixels, " + _loc7_ + " MB");
         }
         return _loc4_;
      }
      
      public function tileSceneBitmaps(param1:ILogger) : Array
      {
         var _loc2_:String = this.url;
         _loc2_ = StringUtil.stripSuffix(_loc2_,".z");
         _loc2_ = StringUtil.stripSuffix(_loc2_,".json");
         return this.landscape.tileLandscapeBitmaps(_loc2_);
      }
      
      public function computeConstrainedBattleBoardBoundary() : Rectangle
      {
         var _loc1_:Rectangle = this.computeBattleBoardBoundary();
         var _loc2_:Number = 150;
         var _loc3_:Number = 150;
         var _loc4_:Number = 400;
         var _loc5_:Number = 350;
         var _loc6_:Number = 400;
         var _loc7_:Number = 400;
         var _loc8_:Number = Math.min(this.cameraMaxWidth + _loc6_,this.boundary.width);
         var _loc9_:Number = Math.min(this.cameraMaxHeight + _loc7_,this.boundary.height);
         var _loc10_:Number = _loc8_ - _loc1_.width;
         var _loc11_:Number = _loc9_ - _loc1_.height;
         if(_loc10_ > 0)
         {
            _loc1_.x -= _loc10_ / 2;
            _loc1_.width += _loc10_;
         }
         if(_loc11_ > 0)
         {
            _loc1_.y -= _loc11_ / 2;
            _loc1_.height += _loc11_;
         }
         return _loc1_;
      }
      
      public function getSpeechBubbleEntities(param1:Dictionary) : void
      {
         if(this.happenings)
         {
            this.happenings.getSpeechBubbleEntities(param1);
         }
      }
      
      public function findActionsForSceneUrl(param1:String, param2:Vector.<ActionDef>) : void
      {
         if(this.happenings)
         {
            this.happenings.findActionsForSceneUrl(param1,param2);
         }
      }
      
      public function findActionsForHappening(param1:HappeningDef, param2:Vector.<ActionDef>) : void
      {
         if(this.happenings)
         {
            this.happenings.findActionsForHappening(param1,param2);
         }
      }
      
      public function findActionsByType(param1:ActionType, param2:Vector.<ActionDef>) : Vector.<ActionDef>
      {
         if(this.happenings)
         {
            return this.happenings.findActionsByType(param1,param2);
         }
         return null;
      }
      
      public function get linkString() : String
      {
         return this.id;
      }
      
      public function getLocationDefs(param1:String, param2:Vector.<ITravelLocationDef>) : Vector.<ITravelLocationDef>
      {
         var _loc4_:TravelDef = null;
         var _loc3_:Vector.<ITravelDef> = !!this._landscape ? this._landscape.getTravels() : null;
         if(_loc3_)
         {
            for each(_loc4_ in _loc3_)
            {
               param2 = _loc4_.getLocationDefs(param1,param2);
            }
         }
         return param2;
      }
      
      public function get hasSceneBattle() : Boolean
      {
         return Boolean(this.boards) && Boolean(this.boards.length);
      }
      
      public function get hasSceneTravel() : Boolean
      {
         return Boolean(this.landscape) && this.landscape.numTravelDefs > 0;
      }
      
      public function get isSceneMap() : Boolean
      {
         return this.url.indexOf("map_camp") > 0;
      }
      
      public function get isSceneStage() : Boolean
      {
         return this.url.indexOf("stage/stg_") > 0;
      }
      
      public function get getHappeningDefProvider() : IHappeningDefProvider
      {
         return this.happenings;
      }
      
      public function get landscape() : ILandscapeDef
      {
         return this._landscape;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get cameraAnchorOnce() : Boolean
      {
         return this._cameraAnchorOnce;
      }
   }
}
