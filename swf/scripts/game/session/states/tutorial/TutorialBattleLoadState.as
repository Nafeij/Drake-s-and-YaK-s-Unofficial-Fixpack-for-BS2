package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityDefVars;
   import engine.entity.def.EntityListDef;
   import engine.resource.ResourceGroup;
   import engine.scene.model.SceneLoaderBattleInfo;
   import flash.events.Event;
   import game.session.states.GameStateDataEnum;
   import game.session.states.SceneLoadState;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class TutorialBattleLoadState extends SceneLoadState
   {
      
      private static const battle_units:Array = [{
         "id":"shieldbanger_tutorial",
         "entityClass":"shieldbanger",
         "autoLevel":1,
         "stats":[{
            "stat":"ARMOR",
            "value":11
         },{
            "stat":"STRENGTH",
            "value":9
         }]
      },{
         "id":"warhawk_tutorial",
         "entityClass":"warhawk",
         "autoLevel":1
      }];
       
      
      private var group:ResourceGroup;
      
      private var loadingGui:Boolean;
      
      public function TutorialBattleLoadState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         var _loc6_:Object = null;
         var _loc7_:BattleCreateData = null;
         var _loc8_:SceneLoaderBattleInfo = null;
         var _loc9_:EntityDefVars = null;
         var _loc4_:String = "common/battle/scene/tutorial/map_tutorial.json.z";
         param1.setValue(GameStateDataEnum.SCENELOADER_PRESERVE,false);
         param1.setValue(GameStateDataEnum.SCENE_URL,_loc4_);
         super(param1,param2,param3);
         this.group = new ResourceGroup(this,param3);
         var _loc5_:EntityListDef = new EntityListDef(config.context.locale,config.classes,param3);
         for each(_loc6_ in battle_units)
         {
            _loc9_ = new EntityDefVars(config.context.locale).fromJson(_loc6_,param3,config.abilityFactory,config.classes,config,true,config.itemDefs,config.statCosts);
            _loc5_.addEntityDef(_loc9_);
         }
         data.setValue(GameStateDataEnum.LOCAL_PARTY,_loc5_);
         _loc7_ = new BattleCreateData();
         _loc7_.scene = _loc4_;
         data.setValue(GameStateDataEnum.BATTLE_CREATE_DATA,_loc7_);
         data.setValue(GameStateDataEnum.LOCAL_TIMER_SECS,0);
         _loc8_ = new SceneLoaderBattleInfo();
         _loc8_.battle_board_id = "*";
         data.setValue(GameStateDataEnum.BATTLE_INFO,_loc8_);
         this.loadingGui = true;
         this.group.addResourceGroupListener(this.guiResourceGroupHandler);
      }
      
      private function guiResourceGroupHandler(param1:Event) : void
      {
         this.checkReady();
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
      }
      
      override protected function handleCleanup() : void
      {
         super.handleCleanup();
      }
      
      override protected function checkReady() : void
      {
         if(!this.loadingGui)
         {
            return;
         }
         if(!this.group.complete)
         {
            return;
         }
         super.checkReady();
      }
   }
}
