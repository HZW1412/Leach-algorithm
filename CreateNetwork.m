function Network = CreateNetwork(Height, Width, sinkX, sinkY)

    % Tworzenie obszaru roboczego (obszar sieci)
    Surface.Height = Height;
    Surface.Width = Width;
    
    % Ustalanie pozycji w�z�a nadrz�dnego(BS)
    Sink.X = sinkX;
    Sink.Y = sinkY;

    Network = struct('Surface', Surface, 'Sink', Sink );
end