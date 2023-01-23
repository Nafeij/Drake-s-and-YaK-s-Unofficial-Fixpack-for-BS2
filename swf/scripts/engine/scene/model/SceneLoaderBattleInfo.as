package engine.scene.model
{
   import engine.battle.board.model.BattleScenarioDef;
   import engine.battle.board.model.BattleSnapshot;
   
   public class SceneLoaderBattleInfo
   {
       
      
      public var url:String;
      
      public var happening:String;
      
      public var battle_bucket:String;
      
      public var battle_bucket_quota:int;
      
      public var battle_bucket_deployment:String;
      
      public var battle_board_id:String;
      
      public var battle_spawn_tags:String;
      
      public var battle_deployment_area:String;
      
      public var scenarioDef:BattleScenarioDef;
      
      public var snap:BattleSnapshot;
      
      public var music_url:String;
      
      public var music_override:Boolean;
      
      public var war:Boolean;
      
      public var sparring:Boolean;
      
      public function SceneLoaderBattleInfo()
      {
         super();
      }
   }
}
