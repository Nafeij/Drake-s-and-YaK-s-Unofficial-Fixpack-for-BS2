package game.gui
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.sim.BattlePartyHornEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.gui.GuiGpBitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.gui.battle.IGuiArtifact;
   import game.gui.battle.IGuiArtifactListener;
   import game.gui.page.BattleHudPage;
   
   public class ArtifactHelper implements IGuiArtifactListener, IArtifactHelper
   {
       
      
      protected var _battleHudPage:BattleHudPage;
      
      protected var _board:BattleBoard;
      
      protected var _artifact:IGuiArtifact;
      
      private var _parties:Vector.<IBattleParty>;
      
      protected var _gpbmp:GuiGpBitmap;
      
      public function ArtifactHelper(param1:BattleHudPage, param2:GuiGpBitmap)
      {
         this._parties = new Vector.<IBattleParty>();
         super();
         this._gpbmp = param2;
         this._battleHudPage = param1;
      }
      
      public function get artifact() : IGuiArtifact
      {
         return this._artifact;
      }
      
      public function showArtifact(param1:Boolean) : void
      {
         this._artifact.artifactVisible = param1;
      }
      
      public function resizeHandler() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = NaN;
         if(this._artifact)
         {
            _loc1_ = this._artifact as MovieClip;
            _loc1_.x = this._battleHudPage.width / 2;
            _loc2_ = BoundedCamera.computeDpiScaling(this._battleHudPage.width,this._battleHudPage.height);
            _loc2_ = Math.min(1.5,_loc2_);
            _loc1_.scaleX = _loc1_.scaleY = _loc2_;
            this._artifact.handleResize();
         }
      }
      
      public function get logger() : ILogger
      {
         return this._battleHudPage.logger;
      }
      
      public function cleanup() : void
      {
         this.board = null;
         if(this._artifact)
         {
            this._artifact.cleanup();
            this._artifact = null;
         }
         this._battleHudPage = null;
         this._parties = null;
      }
      
      public function get board() : BattleBoard
      {
         return this._board;
      }
      
      public function set board(param1:BattleBoard) : void
      {
         if(this._board == param1)
         {
            return;
         }
         if(this._board)
         {
            this._board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            this._board.removeEventListener(BattleBoardEvent.PARTY,this.boardPartyHandler);
            this.unlistenToParties();
         }
         this._board = param1;
         if(this._board)
         {
            this._board.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
            this._board.addEventListener(BattleBoardEvent.PARTY,this.boardPartyHandler);
            this.listenToParties();
            this.boardSetupHandler(null);
         }
      }
      
      protected function listenToParties() : void
      {
         var _loc2_:IBattleParty = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._board.numParties)
         {
            _loc2_ = this._board.getParty(_loc1_);
            _loc2_.addEventListener(BattlePartyHornEvent.HORN,this.partyHornHandler);
            this._parties.push(_loc2_);
            _loc1_++;
         }
      }
      
      protected function unlistenToParties() : void
      {
         var _loc1_:IBattleParty = null;
         for each(_loc1_ in this._parties)
         {
            _loc1_.removeEventListener(BattlePartyHornEvent.HORN,this.partyHornHandler);
         }
         this._parties.splice(0,this._parties.length);
      }
      
      protected function partyHornHandler(param1:BattlePartyHornEvent) : void
      {
         var _loc2_:IBattleParty = param1.party;
         if(_loc2_.id != this.board.sim.fsm.session.credentials.userId.toString())
         {
            this._artifact.enemyCount = _loc2_.artifactChargeCount;
            return;
         }
         this.updateArtifactChargeCount();
      }
      
      protected function boardPartyHandler(param1:BattleBoardEvent) : void
      {
         this.unlistenToParties();
         this.listenToParties();
      }
      
      protected function boardSetupHandler(param1:Event) : void
      {
         if(Boolean(this._artifact) && Boolean(this._board))
         {
            if(this._board.boardSetup)
            {
               this._artifact.artifactVisible = true;
               this._battleHudPage.updateBattleHelp();
            }
            else
            {
               this._artifact.artifactVisible = false;
            }
         }
      }
      
      public function useArtifact() : void
      {
         this.logger.error("ArtifactHelper.useArtifact() Invalid Artifact type, ArtifactHelper is a base class.");
      }
      
      public function guiArtifactUse() : void
      {
         this.useArtifact();
      }
      
      protected function updateArtifactChargeCount() : void
      {
         if(!this._board)
         {
            return;
         }
         var _loc1_:IBattleParty = this._board.getPartyById(this.board.sim.fsm.session.credentials.userId.toString());
         if(Boolean(this._artifact) && Boolean(_loc1_))
         {
            this._artifact.count = _loc1_.artifactChargeCount;
         }
      }
      
      public function getMaxUse() : int
      {
         return !!this._artifact ? this._artifact.maxCount : 0;
      }
   }
}
