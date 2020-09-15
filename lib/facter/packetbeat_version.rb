Facter.add(:packetbeat_version) do
  setcode do
    if Facter::Core::Execution.which('packetbeat')
      packetbeat_version = Facter::Core::Execution.execute('packetbeat version 2>&1')
      %r{packetbeat version:?\s+v?([\w\.]+)}.match(packetbeat_version)[1]
    end
  end
end
