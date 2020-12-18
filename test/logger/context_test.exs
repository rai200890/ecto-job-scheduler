defmodule EctoJobScheduler.Logger.ContextTest do
  use ExUnit.Case, async: true
  alias EctoJobScheduler.Logger.Context

  doctest Context

  require Logger

  describe "get/0" do
    test "returns Logger metadata if Logger metadata is empty" do
      assert Logger.metadata() == []
      assert Context.get() == []
    end

    test "returns Logger metadata if Logger has been set" do
      assert Logger.metadata() == []
      Logger.metadata(some: :thing, other: "thing")

      assert Keyword.equal?(Context.get(), some: :thing, other: "thing")
    end
  end

  describe "put/1" do
    test "sets Logger metadata and context if context is a keyword list" do
      assert Logger.metadata() == []
      assert Context.get() == []

      Context.put(some: :thing)

      assert Keyword.equal?(Context.get(), some: :thing)
      assert Keyword.equal?(Logger.metadata(), some: :thing)

      Context.put(other: "thing")

      assert Keyword.equal?(Context.get(), some: :thing, other: "thing")
      assert Keyword.equal?(Logger.metadata(), some: :thing, other: "thing")
    end

    test "sets Logger metadata and context if context is a map" do
      assert Logger.metadata() == []
      assert Context.get() == []

      Context.put(%{some: :thing})

      assert Keyword.equal?(Context.get(), some: :thing)
      assert Keyword.equal?(Logger.metadata(), some: :thing)

      Context.put(%{"other" => "thing"})

      assert Keyword.equal?(Context.get(), some: :thing, other: "thing")
      assert Keyword.equal?(Logger.metadata(), some: :thing, other: "thing")
    end
  end

  describe "reset/0" do
    test "should clear all metadata" do
      Context.put(some: :thing)
      assert Keyword.equal?(Context.get(), some: :thing)

      assert Context.reset() == :ok
      assert Logger.metadata() == []
    end
  end
end
