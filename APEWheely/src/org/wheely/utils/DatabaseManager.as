package org.wheely.utils
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;

	public class DatabaseManager
	{
		private const BDD:File = File.applicationStorageDirectory.resolvePath("database.sqlite");	
		private var _connection:SQLConnection;
		private var _table:SharedObject;
		private var _highestScore:SharedObject;
		
		public function DatabaseManager()
		{
			_connection = new SQLConnection();
			_table = SharedObject.getLocal("tablexists");
			_highestScore = SharedObject.getLocal("highscore");
			
			if (_table.data.exists == undefined)
				_table.data.exists = false;
		}
		
		/** SQLMode.CREATE = "create" | SQLMode.UPDATE = "update" | SQLMode.READ = "read" **/
		public function open(SQLMode:String):void
		{
			_connection.open(BDD,SQLMode);
			
			if(!_table.data.exists)
			{
				var statement:SQLStatement = new SQLStatement();
				statement.sqlConnection = _connection;
				statement.text= "CREATE TABLE IF NOT EXISTS scores (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,score INTEGER)";
				statement.execute();
				_table.data.exists = true;
			}
		}
		
		public function setLocalScoreList(name:String,score:int):void
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = _connection;
			statement.text = "INSERT INTO scores (name,score) VALUES ('"+name+"','"+score+"')";
			statement.execute();
			_connection.close();
		}
		
		public function getLocalScoreList():Array
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = _connection;
			statement.text = "SELECT name, score FROM scores ORDER BY score DESC";
			statement.execute();
			
			var result:SQLResult = statement.getResult();
			_connection.close();
			
			return result.data;
		}
		
		public function resetDatabase():void
		{
			if(_table.data.exists)
			{
				var statement:SQLStatement = new SQLStatement();
				statement.sqlConnection = _connection;
				statement.text = "DROP TABLE scores";
				statement.execute();
				_connection.close();
				
				_table.data.exists = false;
				_highestScore.data.value = undefined;
			}
		}
	}
}