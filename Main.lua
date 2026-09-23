local Game = game;

-- Services
local Workspace = Game : GetService( "Workspace" );

-- Variables
local CurrentCamera = Workspace.CurrentCamera;

-- Cache
local ColorSequenceKeypointNew = ColorSequenceKeypoint.new;
local ApplyStrokeMode = Enum.ApplyStrokeMode;

local ColorSequenceNew = ColorSequence.new;
local LineJoinMode = Enum.LineJoinMode;

local SetMetatable = setmetatable;
local InstanceNew = Instance.new;

local Vector3Zero = Vector3.zero;

local TableClone = table.clone;
local Vector3New = Vector3.new;
local Vector2New = Vector2.new;

local MathRound = math.round;
local Color3New = Color3.new;

local UDim2New = UDim2.new;

local MathTan = math.tan;
local MathRad = math.rad;

local TypeOf = typeof;

-- Colors
local White = Color3New( 1, 1, 1 );
local Black = Color3New( 0, 0, 0 );

local SequenceWhite = ColorSequenceNew( { ColorSequenceKeypointNew( 0, White ), ColorSequenceKeypointNew( 1, White ) } );
local SequenceBlack = ColorSequenceNew( { ColorSequenceKeypointNew( 0, Black ), ColorSequenceKeypointNew( 1, Black ) } );

-- Main
local CacheObject = { }; do
	CacheObject.__index = CacheObject;

	local RenderCallbacks, RenderObjects = { }, { }; do
		-- Box
		do
			function RenderObjects.Box( Self, Parent )
				local ScreenGui = InstanceNew( "ScreenGui" );
				ScreenGui.ResetOnSpawn = false;
				ScreenGui.Parent = Parent;

				local Outline = InstanceNew( "Frame" );
				Outline.BackgroundColor3 = White;
				Outline.BorderColor3 = Black;

				Outline.Parent = ScreenGui;
				Outline.Name = "Outline";

				Outline.BackgroundTransparency = 1;
				Outline.BorderSizePixel = 0;

				local OutlineStroke = InstanceNew( "UIStroke" );
				OutlineStroke.Name = "Stroke";

				OutlineStroke.ApplyStrokeMode = ApplyStrokeMode.Border;
				OutlineStroke.LineJoinMode = LineJoinMode.Miter;

				OutlineStroke.Parent = Outline;
				OutlineStroke.Thickness = 3;

				local OutlineGradient = InstanceNew( "UIGradient" );
				OutlineGradient.Parent = OutlineStroke;
				OutlineGradient.Name = "Gradient";

				local Fill = InstanceNew( "Frame" );
				Fill.Name = "Fill";

				Fill.Position = UDim2New( 0, -1, 0, -1 );
				Fill.Size = UDim2New( 1, 2, 1, 2 );

				Fill.BackgroundTransparency = 1;
				Fill.BorderSizePixel = 0;

				Fill.BackgroundColor3 = White;
				Fill.BorderColor3 = Black;

				Fill.Parent = Outline;

				local FillStroke = InstanceNew( "UIStroke" );
				FillStroke.Name = "Stroke";

				FillStroke.ApplyStrokeMode = ApplyStrokeMode.Border;
				FillStroke.LineJoinMode = LineJoinMode.Miter;

				FillStroke.Color = White;
				FillStroke.Parent = Fill;

				local FillGradient = InstanceNew( "UIGradient" );
				FillGradient.Parent = FillStroke;
				FillGradient.Name = "Gradient";

				return ScreenGui;
			end

			function RenderCallbacks.Box( Self, Data )
				local RenderObject = Self : GetRenderObject( "Box" );

				if ( not RenderObject ) or ( not Data ) then
					RenderObject.Enabled = false;

					return;
				end

				local Position, Distance, Size = Self : GetRender( );

				if ( not Position ) then
					RenderObject.Enabled = false;

					return;
				end

				local OutlineFrame = RenderObject : FindFirstChild( "Outline" );

				if ( not OutlineFrame ) then
					return;
				end

				local FillFrame = OutlineFrame.Fill;

				local OutlineStroke = OutlineFrame.Stroke;
				local FillStroke = FillFrame.Stroke;

				local OutlineGradient = OutlineStroke.Gradient;
				local FillGradient = FillStroke.Gradient;

				OutlineGradient.Color = ( Data.OutlineColor or SequenceBlack );
				FillGradient.Color = ( Data.FillColor or SequenceWhite );

				OutlineGradient.Rotation = ( Data.OutlineRotation or 0 );
				FillGradient.Rotation = ( Data.FillRotation or 0 );

				OutlineFrame.Position = UDim2New( 0, Position.X, 0, Position.Y );
				OutlineFrame.Size = UDim2New( 0, Size.X, 0, Size.Y );

				RenderObject.Enabled = true;

				OutlineFrame.Visible = true;
				FillFrame.Visible = true;
			end
		end
	end

	function CacheObject : Initiate( Parent, Name, InitCallback, DeadCallback )
		local ClassObject, Elements = SetMetatable( { }, self ), TableClone( RenderObjects ); do
			ClassObject.DeathCallback = DeadCallback;
			ClassObject.RenderObjects = Elements;
			
			ClassObject.Name = ( Name or "" );
			ClassObject.Configuration = { };
		end

		for ObjectName, Value in Elements do
			Elements[ ObjectName ] = Value( self, Parent );
		end

		if ( InitCallback ) then
			InitCallback( ClassObject );
		end

		return ClassObject;
	end

	CacheObject.Offset = Vector3New( 0, -.2, 0 );
	CacheObject.Size = Vector3New( 4.2, 5, 0 );

	CacheObject.Position = Vector3Zero;
	CacheObject.Transparency = 0;

	CacheObject.MaxHealth = 100;
	CacheObject.Health = 100;

	CacheObject.RenderObjects = { };
	CacheObject.Configuration = { };
	
	CacheObject.DeathCallback = nil;
	CacheObject.Dead = false;

	-- Methods
	do
		function CacheObject : GetRenderObject( Name )
			return self.RenderObjects[ Name ];
		end
		
		function CacheObject : SetDeathState( State )
			if ( self.Dead ~= State ) and ( State ) then
				local Callback = self.DeathCallback;
				
				if ( Callback ) then
					Callback( self );
				end
			end
			
			self.Dead = State;
		end

		function CacheObject : GetRender( )
			local ScreenPosition = self : GetScreen( );

			if ( not ScreenPosition ) then
				return;
			end

			local Distance = ScreenPosition.Z;
			local Scale = ( 2 * CurrentCamera.ViewportSize.Y ) / ( ( 2 * Distance * MathTan( MathRad( CurrentCamera.FieldOfView ) * .5 ) ) * 2 );

			local Size = self.Size;
				local SizeX = Size.X;
				local SizeY = Size.Y;

			local Height = MathRound( SizeY * Scale );
			local Width = MathRound( SizeX * Scale );

			return Vector2New( MathRound( ScreenPosition.X - ( Width * .5 ) ), MathRound( ScreenPosition.Y - ( Height * .5 ) ) ), Distance, Vector2New( Width, Height );
		end

		function CacheObject : GetScreen( )
			local Result, OnScreen = CurrentCamera : WorldToScreenPoint( self.Position + self.Offset );

			if ( not OnScreen ) then
				return;
			end

			return Result;
		end

		function CacheObject : Stepper( )
			for Name, Callback in RenderCallbacks do
				local RenderObject = self : GetRenderObject( Name );
				
				local Data = self.Configuration[ Name ];
				local Dead = self.Dead;
				
				Callback( self, Data );

				if ( not Data ) and ( RenderObject ) then -- Want it disabled? Remove it from the table.
					local TypeName = TypeOf( RenderObject );

					if ( TypeName == "ScreenGui" ) then
						RenderObject.Enabled = false;

						continue;
					end

					for Index, Value in RenderObject : GetDescendants( ) do
						if ( not Value : IsA( "GuiObject" ) ) then
							continue;
						end

						Value.Visible = false;
					end

					continue;
				end
			end
		end
		
		function CacheObject : Destroy( )
			for Index, Value in self.RenderObjects do
				Value : Destroy( );
			end
		end
	end
end

--[[
local Cache = { }; game : GetService( "RunService" ).PreRender : Connect( function( )
	for _, Player in game : GetService( "Players" ) : GetPlayers( ) do
		local Character = Player.Character;

		if ( not Character ) then
			continue;
		end

		local RootPart = Character : FindFirstChild( "HumanoidRootPart" );

		if ( not RootPart ) then
			continue;
		end

		local Humanoid = Character : FindFirstChild( "Humanoid" );

		if ( not Humanoid ) then
			continue;
		end

		local Object = Cache[ Player ] or CacheObject : Initiate( gethui( ), Player.Name, function( Self )
			Self.Configuration[ "Box" ] = {
				[ "OutlineColor" ] = SequenceBlack,
				[ "FillColor" ] = SequenceWhite,
				
				[ "OutlineRotation" ] = 0,
				[ "FillRotation" ] = 0,
			};
			
			Cache[ Player ] = Self;
		end, function( Self )
			Cache[ Player ] = nil; Self : Destroy( );
		end )

		local Health = Humanoid.Health;
		Object.Health = Health;

		if ( Health >= 1 ) then
			Object.Position = RootPart.Position;
			Object : SetDeathState( false );
		end

		if ( Health <= 0 ) then
			Object : SetDeathState( true );
		end

		Object : Stepper( );
	end
end )
]]

return CacheObject;
