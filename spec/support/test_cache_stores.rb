module Stormpath
  module Test
    class FakeStore1 < Stormpath::Cache::MemoryStore
    end

    class FakeStore2 < Stormpath::Cache::MemoryStore
    end
  end
end
